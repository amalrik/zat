<!-- title: Lists and task lists -->
<!-- labels: milestone:mvp, area:parser, area:renderer, type:feature -->
<!-- milestone: M1 · MVP -->
## Goal

Render nested ordered and bullet lists, and task lists, with correct indentation when a line wraps.

## Rules

- **Parser:**
  - `[ ]` or `[x]` at the start of an item's first paragraph becomes the attribute `task: :open` or `task: :done`.
  - This only applies inside lists, as in GFM.
- **Renderer:**
  - Bullets per level: `•` `◦` `▪`, cycling.
  - Ordered lists honor the start number; numbers are right-aligned.
  - Task lists use `☐` and `☑`; done items are dimmed.
  - A wrapped line continues aligned with the text, not with the marker.
  - Loose lists have a blank line between items; tight lists don't.
  - Blocks inside an item inherit its indentation.

## Acceptance criteria

- [ ] Fixtures: tight, loose, 4 levels deep, starting at 7, mixed, and a task list
- [ ] A long item wrapped at 40 columns
- [ ] A code block inside an item
