# ADR 0001: Zat has its own Markdown parser

- **Status:** accepted
- **Date:** 2026-10-17
- **Issue:** #3

## Context

Zat exists to produce feedback on ZJIT and Ractors for Ruby 4.1 (see [PLANNING.md](../PLANNING.md)). The parser therefore has two requirements beyond correctness:

1. **The whole pipeline must run inside a non-main Ractor**, for batch mode (#30) and the Ractor lab (#32).
2. **Parsing time should be spent in Ruby code ZJIT can compile**, not in C, or the measurements say little about ZJIT.

We evaluated the pure-Ruby options on 2026-10-17:

| Option | Pure Ruby | Works in a Ractor | Notes |
|---|---|---|---|
| kramdown 2.5 + kramdown-parser-gfm 1.1 | ✅ | ❌ `Ractor::IsolationError`: `@options` on `Kramdown::Options` | Under YJIT, parsing gets only ~1.25x faster (4.0.7, ~9,800 lines): its time is dominated by regex in Onigmo |
| RDoc::Markdown (rdoc 8.1, bundled with Ruby) | ✅ (kpeg-generated) | ❌ `Ractor::IsolationError`: unshareable constant `DEFAULT_EXTENSIONS` | peg-markdown dialect, not CommonMark; ~0.2 ms/line, roughly twice kramdown's per-line cost in quick runs (different inputs, so only indicative) |
| commonmarker, redcarpet | ❌ (Rust / C extensions) | — | Out: the project is pure Ruby |
| Patching kramdown to be Ractor-safe | ✅ | Possible | Still regex-bound for ZJIT, and we'd maintain a fork |

The same audit found that Rouge and unicode-display_width also fail inside Ractors, while `Prism.lex` and `Array#pack("m0")` work. That is why Zat has zero runtime dependencies (#2).

## Decision

### 1. An own two-phase parser, `Zat::Markdown`

The parser follows the strategy described in the [CommonMark spec](https://spec.commonmark.org/0.31.2/) (appendix, "A parsing strategy"):

1. **Blocks** (#7): line by line, keeping a stack of open container blocks and the current leaf block. Inline content stays raw.
2. **Inlines** (#8): the raw text of paragraphs, headings and table cells becomes inline nodes, with emphasis resolved by the spec's delimiter-stack algorithm.

References:

- CommonMark spec **0.31.2**;
- GFM spec **0.29-gfm** for tables, strikethrough, task lists and extended autolinks.

The supported subset is listed in PLANNING §1.2. Deviations are tracked in [known-differences.md](../known-differences.md).

### 2. The AST: one `Data` class, typed by a symbol

```ruby
Zat::Markdown::Node = Data.define(:type, :value, :attrs, :children, :line)
```

- `value` holds literal content (only for leaf literal types); `attrs` holds type-specific attributes; `line` is the 1-based source line of blocks.
- Defaults are shared frozen constants (`NO_ATTRS`, `NO_CHILDREN`), so the many leaf nodes don't allocate empty hashes and arrays.
- Optional attributes are **omitted** rather than set to `nil`, so pattern matching reads naturally: `in {type: :item, attrs: {task: :done}}`.
- Nodes are values: `==` compares fields, which keeps test assertions simple.

**Why one class rather than a class per node type** (as Prism does): consumers dispatch with `case node.type`; every node has the same shape, so call sites like `node.children` see a single class; and the AST stays a plain data format, easy to normalize against kramdown (#5) and to extract as a gem. A class-per-type AST is one of the variants in the dispatch microbenchmark (#27). If it wins clearly under ZJIT without hurting readability, this decision gets revisited there.

Type names follow the CommonMark spec's vocabulary:

**Blocks** (all have `line`)

| Type | value | attrs | children |
|---|---|---|---|
| `:document` | — | — | blocks |
| `:heading` | — | `level:` 1–6 | inlines |
| `:paragraph` | — | — | inlines |
| `:block_quote` | — | — | blocks |
| `:list` | — | `ordered:` bool, `start:` Integer (ordered only), `tight:` bool, `marker:` `"-"` `"*"` `"+"` `"."` `")"` | `:item` |
| `:item` | — | `task:` `:open` / `:done` (task items only) | blocks |
| `:code_block` | literal code | `fenced:` bool, `info:` String (fenced with an info string only) | — |
| `:html_block` | raw HTML | — | — |
| `:thematic_break` | — | — | — |
| `:table` | — | `alignments:` Array of `:left` `:center` `:right` `nil` | `:table_row` |
| `:table_row` | — | `header:` true (header row only) | `:table_cell` |
| `:table_cell` | — | — | inlines |

**Inlines** (`line` is nil)

| Type | value | attrs | children |
|---|---|---|---|
| `:text` | text | — | — |
| `:softbreak`, `:linebreak` | — | — | — |
| `:code` | literal code | — | — |
| `:emph`, `:strong`, `:strikethrough` | — | — | inlines |
| `:link` | — | `destination:`, `title:` (optional), `autolink:` true (autolinks only) | inlines |
| `:image` | — | `destination:`, `title:` (optional) | inlines (the alt text) |
| `:html_inline` | raw HTML | — | — |

### 3. Ractor-safety rules

1. Every constant is a frozen literal or passed through `Ractor.make_shareable`.
2. No class or module instance variable is written after load: no `@cache ||=` on `self`.
3. No global or lazy caches. Caches, when needed, live on instances.
4. `Zat::Markdown.parse` returns `Ractor.make_shareable(document)`. The parser may use mutable builders internally, but what it returns is deeply frozen and can be sent to any Ractor without copying.

Enforced by #31 (the pipeline runs inside a Ractor in CI) and by `test/markdown/node_test.rb` from now on.

### 4. Independence from the rest of Zat

`Zat::Markdown` requires nothing outside `lib/zat/markdown*` and knows nothing about terminals. `test/markdown/boundary_test.rb` checks this in a fresh process. Extracting the gem means moving `lib/zat/markdown*` and `test/markdown/`, then renaming the namespace.

### 5. Scanning style: idiomatic first

Code is written to read well: `StringScanner` and regex where they make the intent clear, plain loops elsewhere. Byte-level variants (`getbyte`, `byteindex`) live in microbenchmarks (#27) and move into the parser only when they win under ZJIT **and** remain readable. The parser must not be shaped to flatter the JIT; that would bias every number the lab produces.

### 6. kramdown stays, as a development tool

kramdown is a development dependency only:

- reference AST in `script/dump_ast.rb --kramdown`;
- oracle for differential tests (#5);
- comparison point in benchmarks (#26).

#5 has to normalize its AST, which differs from ours in non-obvious ways:

| kramdown | Zat |
|---|---|
| `ul` / `ol`, `options[:first_list_marker]` | `:list` with `ordered:` and `marker:` |
| `li` containing `html_element "input"` with `"type" => "checkbox"` | `:item` with `task:` (`checked` attr → `:done`) |
| `p` with `options[:transparent]` inside tight lists | `:paragraph` (tightness lives on `:list`) |
| `html_element "del"` | `:strikethrough` |
| `codeblock`, `options[:fenced]`, `options[:lang]` | `:code_block` with `fenced:` and `info:` |
| `codespan`, `em` | `:code`, `:emph` |
| `table` > `thead`/`tbody` > `tr` > `td`, `options[:alignment]` | `:table` > `:table_row` (`header:`) > `:table_cell` |
| `smart_quote`, `typographic_sym`, `entity` | `:text` (Zat does no typographic substitution) |
| `blank` | dropped |

## Consequences

**Good**

- The pipeline can run in Ractors end to end. That is the precondition for #30 and #32.
- Parsing becomes Ruby code we wrote and can measure phase by phase. It's a fair ZJIT workload and a direct comparison against kramdown.
- No runtime dependencies to audit, pin or fork.
- The parser can become its own gem: a pure-Ruby, Ractor-safe CommonMark parser that doesn't exist today.

**Bad**

- The biggest chunk of work in the project: #7 and #8 are the two largest issues, and CommonMark has many edge cases. The documented subset and the spec-driven tests (#5) are what keep this bounded.
- We own correctness. Bugs kramdown fixed years ago may reappear; the differential tests exist to catch them.
- Not full CommonMark at first (reference links and footnotes are deferred). Users comparing against mdcat will notice.

**To watch**

- The cost of `Ractor.make_shareable` on large documents. It walks the whole tree, and #24 measures it. If it matters, the parser can freeze nodes as it builds them and skip the final walk.
