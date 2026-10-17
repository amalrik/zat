<!-- title: ADR: own parser and Ractor-safety rules -->
<!-- labels: milestone:setup, area:parser, gem:markdown, ractor-safety, type:research -->
<!-- milestone: M0 · Foundation -->
## Goal

Record in `docs/adr/0001-own-parser.md` why Zat has its own Markdown parser and the rules it follows.

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
7. **kramdown** is a development dependency, used as an oracle and a comparison point.

## Acceptance criteria

- [ ] ADR written with context, decision, alternatives and consequences
- [ ] Node types and their attributes listed
- [ ] `script/dump_ast.rb file.md` prints Zat's AST (and kramdown's with `--kramdown`)
