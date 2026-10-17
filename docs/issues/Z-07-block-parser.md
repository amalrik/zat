<!-- title: Block parser -->
<!-- labels: milestone:mvp, area:parser, gem:markdown, zjit:hot-path, ractor-safety, type:feature -->
<!-- milestone: M1 · MVP -->
## Goal

First phase of `Zat::Markdown`: turn text into a tree of blocks, following the CommonMark spec strategy (open container blocks + current leaf block, line by line).

## Scope

- ATX and setext headings; paragraphs; thematic breaks.
- Block quotes, nested.
- Lists: markers, start numbers, tight/loose, nesting by indentation.
- Fenced code (` ``` ` and `~~~`, info string, closing fence at least as long as the opening one).
- Indented code; blank lines.
- GFM tables: detection and cell splitting only (layout comes in #14).
- HTML blocks: a single `:html_block` node with the raw text.

## Rules

- Input: a UTF-8 `String`. Normalizes `\r\n` and expands tabs to 4-column stops in indentation, as the spec requires.
- Inline text (paragraph and heading content) **stays raw** in the node, for #8 to process.
- Linear in input size: no backtracking across lines.
- Immutable `Data.define` nodes. The result passes `Ractor.shareable?` after `make_shareable`.
- Source position (line) on every block, for error messages and future features.

## Acceptance criteria

- [ ] The spec's block sections pass (#5)
- [ ] A 100k-line document parses in linear time (sanity test: 10k vs 100k)
- [ ] `Ractor.new { Zat::Markdown.parse(src) }.value` works
- [ ] No `require` of code outside `zat/markdown`
- [ ] `script/dump_ast.rb FILE` prints the AST as an indented tree (moved here from #3)
