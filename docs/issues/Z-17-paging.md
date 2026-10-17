<!-- title: Paging via $PAGER -->
<!-- labels: milestone:advanced, area:cli, type:feature -->
<!-- milestone: M2 · Advanced experience -->
## Goal

An `mdless` equivalent: send the output to a pager.

## Rules

- `-p/--paginate` forces the pager; `-P/--no-pager` disables it.
- Uses `$PAGER` when set, otherwise `less -R`. Makes sure `R` is in `$LESS`.
- Only pages when the output is a TTY. If the pager is missing, warns on stderr and writes directly.

## Acceptance criteria

- [ ] `zat -p README.md` opens in less with colors
- [ ] Quitting the pager early prints no stack trace
- [ ] `PAGER=cat` works
- [ ] Test with a fake pager
