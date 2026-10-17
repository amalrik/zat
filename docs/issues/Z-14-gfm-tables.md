<!-- title: GFM tables with Unicode borders -->
<!-- labels: milestone:advanced, area:tables, area:parser, zjit:hot-path, type:feature -->
<!-- milestone: M2 · Advanced experience -->
## Goal

Complete GFM tables: spec-compliant parsing and aligned layout with Unicode borders.

## Rules

**Parser**

- Delimiter row with `:--`, `:-:` and `--:`.
- Escaped pipes (`\|`).
- Extra or missing cells are adjusted as the GFM spec says.
- Cell content goes through the inline parser.

**Layout (`Zat::Table`)**

- Borders `┌─┬─┐ │ ├─┼─┤ └─┴─┘`; the header is bold, followed by a `╞═╪═╡` separator.
- Per-column alignment.
- Column widths:
  1. natural width of each column;
  2. if the table doesn't fit, shrink the widest columns proportionally, down to 6;
  3. text wraps inside cells;
  4. if it still doesn't fit, switch to record mode (`column: value`).
- `ZAT_ASCII=1` switches borders to `+-|`.

## Acceptance criteria

- [ ] The GFM spec's table section passes (#5)
- [ ] Fixtures: simple, alignments, empty cells, CJK, inline content, 60 columns, and 30 columns (record mode)
- [ ] No line exceeds `columns`; vertical borders line up
- [ ] A 1,000-row table renders in linear time
