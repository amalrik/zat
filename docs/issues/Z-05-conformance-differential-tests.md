<!-- title: Parser conformance and differential tests -->
<!-- labels: milestone:setup, area:parser, area:tests, gem:markdown, type:feature -->
<!-- milestone: M0 · Foundation -->
## Goal

Make sure the own parser is correct, using the CommonMark/GFM spec and kramdown as references.

## Rules

- **Conformance:** the CommonMark spec examples and the GFM extension examples (official JSON, pinned by hash) are loaded as tests. Each example is tagged `:pass`, `:known_difference` (with a justification) or `:out_of_scope`. Comparison is structural, on a normalized AST, not on generated HTML.
- **Differential:** the same document goes through `Zat::Markdown` and kramdown-GFM; both ASTs are normalized to a common shape (types and text) and compared. Runs over the corpus (#22) and over seeded random documents.
- Every divergence is a Zat bug, a known difference, or a kramdown deviation from the spec. The last kind is documented and is not our bug.
- `rake spec:report` shows the share of spec examples passing, per section.
- Every parsed tree also passes `assert_valid_ast` (`test/markdown/support/ast_schema.rb`).

## kramdown's AST vs ours

Found while writing `script/dump_ast.rb` (#3). This is the normalizer's starting point; the normalizer's code becomes the source of truth.

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

## Acceptance criteria

- [ ] Spec example loader with per-example status
- [ ] AST normalizer for Zat and for kramdown
- [ ] Differential test over the corpus and over seeded random generation
- [ ] Conformance report per spec section
- [ ] v1 target: 100% `:pass` in the sections of the supported subset
