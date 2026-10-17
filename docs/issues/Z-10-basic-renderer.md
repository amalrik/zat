<!-- title: Renderer: basic blocks and inlines -->
<!-- labels: milestone:mvp, area:renderer, zjit:hot-path, type:feature -->
<!-- milestone: M1 · MVP -->
## Goal

`Zat::Renderer`: walks the `Zat::Markdown` AST and writes into a single buffer.

## Elements

- **Blocks:**
  - headings h1–h6 (h1 and h2 emphasized with `━` and `─`);
  - paragraph;
  - block quote with `│` (nestable);
  - horizontal rule;
  - code, provisionally without highlighting (highlighting comes in #15);
  - `:html_block` as dimmed text.
- **Inlines:** bold, italic, both combined, code span, strikethrough, line breaks, and dimmed inline HTML.

## Rules

- Single buffer: `String.new(capacity: source.bytesize * 2)` with `<<`.
- Dispatch with `case node.type`.
- Style stack: closing an inner style reopens the outer one.
- No global state; one renderer instance per document.

## Acceptance criteria

- [ ] A golden fixture for each element and for nestings
- [ ] `:none` produces plain text with no leftover escapes
- [ ] Renders mdcat's `README.md` and Ruby's `NEWS.md` without errors
- [ ] Rendering works inside a Ractor
