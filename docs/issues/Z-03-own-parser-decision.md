<!-- title: Record the own-parser decision and the AST contract -->
<!-- labels: milestone:setup, area:parser, gem:markdown, ractor-safety, type:research -->
<!-- milestone: M0 · Foundation -->
## Goal

Record why Zat has its own Markdown parser, and define the AST it produces.

> Changed during review (#34): no ADR series. Decisions go to a single `docs/decisions.md` log (why / why not / revisit when), contracts live in code and tests, and `docs/ARCHITECTURE.md` gives a short overview.

## Context (measured 2026-10-17, Ruby 4.0.7)

- Inside a Ractor, kramdown, Rouge and unicode-display_width all fail with `Ractor::IsolationError`, because they keep mutable state on classes. Prism and `pack("m0")` work.
- Under YJIT, kramdown's parse got only ~1.25x faster, because its time is dominated by regex in Onigmo.
- Native gems (`commonmarker`, `redcarpet`) are ruled out: the project is pure Ruby.

## Decisions to record

1. `Zat::Markdown` is an own two-phase parser (blocks, then inlines), modeled on the CommonMark spec.
2. The supported subset and known differences (PLANNING §1.2) are tracked in `docs/known-differences.md`.
3. **AST:** `Data.define` nodes (`type`, `children`, attributes), immutable after parsing and shareable.
4. **Ractor-safety:**
   - constants frozen or `make_shareable`;
   - no class-level instance variables written after load;
   - no global caches.
5. **Independence:** `Zat::Markdown` references nothing in `Zat::` outside its own namespace, ready for gem extraction.
6. **Scanning:** idiomatic by default (`StringScanner` where it reads clearly); byte-level variants live in microbenchmarks until the numbers justify switching.
7. **kramdown** is not a dependency at all (changed in review): the spec examples are the correctness oracle, and benchmarks install it from `bench/Gemfile`.

## Acceptance criteria

- [x] `docs/decisions.md` entries: own parser and zero dependencies, node model, Ractor-safety, scanning style
- [x] AST contract as code: `Zat::Markdown::Node` plus `test/markdown/support/ast_schema.rb` with `assert_valid_ast`
- [x] `docs/ARCHITECTURE.md` and a repo `CLAUDE.md`
