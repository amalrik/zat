<!-- title: CLI: file and stdin input -->
<!-- labels: milestone:mvp, area:cli, type:feature -->
<!-- milestone: M1 · MVP -->
## Goal

`Zat::CLI`: reads arguments, opens inputs, and performs a single write per document.

## Rules

- `zat a.md [b.md…]` renders the files in order, separated by a blank line. `zat` with no arguments, or `zat -`, reads stdin.
- Input is UTF-8; invalid bytes go through `scrub`.
- Options (OptionParser):
  - `-h`, `-V`, `-c/--columns N`;
  - `--no-color`, `--ansi`;
  - `-l/--local`, `--fail`;
  - `-j/--jobs N` (reserved for #30).
- Exit codes: `0` success; `1` some file failed (the rest still render, unless `--fail`); `2` usage error.
- `EPIPE` exits silently with status 0.

## Acceptance criteria

- [ ] File, multiple files and stdin all work
- [ ] Errors on stderr formatted as `zat: <file>: <reason>`
- [ ] `zat x.md | head -1` prints no stack trace
- [ ] Integration tests via `Open3`
