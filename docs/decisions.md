# Decisions

Why Zat is shaped the way it is, and especially why things are *absent*, which code can't explain. Each entry records the evidence of its day and says when to revisit it.

This is history, not law. When evidence contradicts an entry, change direction and add a new entry that supersedes it. Contracts (AST types, formats) live in code and tests, not here.

---

## 2026-10-17 · ZJIT is the target, YJIT only a reference

**Decision.** Measurements and feedback target ZJIT on Ruby 4.1. YJIT appears only as a comparison column ("has ZJIT caught up?").

**Why.** ZJIT is YJIT's successor; feedback is worth most where the compiler is still being shaped.

**Revisit when** ZJIT stops being the direction for Ruby's JIT.

---

## 2026-10-17 · Own Markdown parser, zero runtime dependencies

**Decision.** `Zat::Markdown` is our own parser, following the CommonMark spec 0.31.2 and GFM 0.29-gfm, built to be extractable as a gem. Zat has no runtime dependencies. kramdown is used only in development: AST dumps, differential tests (#5) and benchmark comparisons.

**Evidence.** Ruby 4.0.7 / 4.1.0-preview1, running each library inside a non-main Ractor:

| Library | In a Ractor |
|---|---|
| kramdown 2.5 + GFM 1.1 | ❌ `@options` on `Kramdown::Options` |
| RDoc::Markdown (rdoc 8.1, bundled) | ❌ unshareable constant `DEFAULT_EXTENSIONS`; also not CommonMark |
| Rouge 5.1 | ❌ `@registry`, `eager_load!` |
| unicode-display_width 3.3 | ❌ `EmojiSupport.recommended` |
| `Prism.lex`, `Array#pack("m0")` | ✅ |

Under YJIT, kramdown's parse got only ~1.25x faster (regex-bound), so it says little about a JIT anyway.

**Rejected.**
- commonmarker and redcarpet: native extensions.
- A Ractor-safe fork of kramdown: we'd maintain a fork, and its parse would still be regex-bound.

**Revisit when** a pure-Ruby CommonMark parser becomes Ractor-safe, or Ractors stop being a goal.

---

## 2026-10-17 · One node class, typed by a symbol

**Decision.** The AST is `Zat::Markdown::Node`, a single `Data` class with `type`, `value`, `attrs`, `children`, `line`. Consumers dispatch with `case node.type`. Type names follow the CommonMark spec (`:block_quote`, `:emph`, `:softbreak`…).

**Why.**
- Every node has the same shape, so call sites like `node.children` see one class.
- The AST is a plain data format, easy to normalize against kramdown and to extract as a gem.

**Rejected.** A class per node type (Prism's approach).

**Revisit when** the dispatch microbenchmark (#27) shows class-per-type clearly faster under ZJIT without hurting readability.

---

## 2026-10-17 · Ractor-safe by construction

**Decision.** `Zat::Markdown.parse` returns `Ractor.make_shareable(document)`. Constants are frozen or shareable, and there's no class-level mutable state or global cache anywhere in `lib/`. Enforced by tests (#31).

**Why.** Batch mode (#30) and the Ractor lab (#32) need the whole pipeline to run in any Ractor.

**Revisit when** `make_shareable`'s full-tree walk shows up in profiles (#24). The alternative is to freeze nodes as they're built.

---

## 2026-10-17 · Idiomatic scanning first

**Decision.** The parser uses whatever reads best (`StringScanner`, regex, plain loops). Byte-level variants (`getbyte`, `byteindex`) stay in microbenchmarks (#27).

**Why.** A parser shaped to flatter the JIT would bias every measurement the lab produces.

**Revisit when** a variant wins under ZJIT **and** reads just as well. Then it moves into the parser.

---

## 2026-10-17 · Executables in `exe/`, not `bin/`

**Decision.** The gem's executable is `exe/zat`.

**Why.** Since Bundler 1.8, `exe/` holds the executables a gem installs and `bin/` holds the repository's development scripts and binstubs, which `bundle binstubs` can overwrite.

**Revisit when** the user prefers otherwise.
