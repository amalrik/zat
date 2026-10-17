<!-- title: Inline parser -->
<!-- labels: milestone:mvp, area:parser, gem:markdown, zjit:hot-path, ractor-safety, type:feature -->
<!-- milestone: M1 · MVP -->
## Goal

Second phase of `Zat::Markdown`: turn the raw text of paragraphs, headings and table cells into inline nodes.

## Scope

- Backslash escapes and entities (own frozen table in `entities.rb`, generated from the official HTML5 list).
- Code spans.
- Emphasis and strong via the spec's *delimiter stack* algorithm (`*` and `_`, left/right-flanking rules).
- GFM strikethrough (`~~`).
- Inline links and images: `[t](url "title")` and `![alt](src)`.
- `<…>` autolinks and GFM extended autolinks (`www.`, `http(s)://`).
- Hard and soft line breaks.

## Rules

- The delimiter algorithm is implemented directly and readably. It is the parser's main hot path and the target of #27.
- No per-character substring allocation: work with byte indices and slice only when emitting text nodes.
- Adjacent text is merged into a single `:text` node.

## Acceptance criteria

- [ ] The spec's inline sections within the subset pass (#5)
- [ ] Pathological tests: `*` × 10,000 and nested brackets are not quadratic (spec cases)
- [ ] Seeded random input never raises, and every tree passes `assert_valid_ast` (#5)
- [ ] Works inside a Ractor
