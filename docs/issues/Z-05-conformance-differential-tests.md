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

## Acceptance criteria

- [ ] Spec example loader with per-example status
- [ ] AST normalizer for Zat and for kramdown
- [ ] Differential test over the corpus and over seeded random generation
- [ ] Conformance report per spec section
- [ ] v1 target: 100% `:pass` in the sections of the supported subset
