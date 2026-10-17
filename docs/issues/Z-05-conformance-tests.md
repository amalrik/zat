<!-- title: Parser conformance tests (CommonMark/GFM spec) -->
<!-- labels: milestone:setup, area:parser, area:tests, gem:markdown, type:feature -->
<!-- milestone: M0 · Foundation -->
## Goal

Make sure the own parser is correct, using the official CommonMark and GFM spec examples as the oracle.

> Changed in #34: no differential testing against kramdown. kramdown isn't CommonMark-compliant, so comparing against it mostly surfaces *its* deviations. The spec examples are the real oracle.

## Rules

- **Conformance:** the CommonMark spec examples and the GFM extension examples (official JSON, pinned by hash) are loaded as tests. Each example is tagged `:pass`, `:known_difference` (with a justification) or `:out_of_scope`. Comparison is structural, on a normalized AST, not on generated HTML.
- **Robustness:** seeded random documents (and the corpus from #22) never make the parser raise, and every tree passes `assert_valid_ast`.
- `rake spec:report` shows the share of spec examples passing, per section.
- Every parsed tree also passes `assert_valid_ast` (`test/markdown/support/ast_schema.rb`).


## Acceptance criteria

- [ ] Spec example loader with per-example status
- [ ] Seeded random-document robustness test
- [ ] Conformance report per spec section
- [ ] v1 target: 100% `:pass` in the sections of the supported subset
