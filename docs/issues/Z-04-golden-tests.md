<!-- title: Golden tests for ANSI output -->
<!-- labels: milestone:setup, area:tests, type:chore -->
<!-- milestone: M0 · Foundation -->
## Goal

Visual regression testing: every `.md` fixture has an expected `.ansi` output, compared byte for byte.

## Rules

- Fixtures in `test/fixtures/<name>.md`; expected outputs in `test/fixtures/<name>.<cols>.ansi`.
- Tests use a fixed `Terminal`: 80 columns, truecolor, OSC 8 on, no images. The real environment never leaks in.
- `ZAT_UPDATE_GOLDEN=1 rake test` rewrites the expected outputs.
- Diffs show escapes in readable form (`\e[1m`).

## Acceptance criteria

- [ ] `assert_golden(name, columns: 80)` helper
- [ ] Update mode
- [ ] Readable diff
- [ ] `rake golden:show[name]` for visual inspection
- [ ] Goldens also pass under `--zjit` in CI. A difference there is a miscompilation candidate to report (#28)
