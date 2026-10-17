<!-- title: Terminal, Style and Theme -->
<!-- labels: milestone:mvp, area:terminal, ractor-safety, type:feature -->
<!-- milestone: M1 · MVP -->
## Goal

Separate three responsibilities: what the terminal supports (`Terminal`), how a style becomes bytes (`Style`), and which style each element uses (`Theme`).

## Rules

**`Zat::Terminal`**

- A `Data` resolved **once**, in the main Ractor, with these fields:
  - `tty?`;
  - `columns`: from `io/console`, then `$COLUMNS`, then 80;
  - `color_depth`;
  - `hyperlinks?`;
  - `image_protocol`.
- `color_depth` is decided in this order:
  1. `NO_COLOR` set → `:none`;
  2. not a TTY and no `--ansi` → `:none`;
  3. `COLORTERM` is `truecolor` or `24bit` → `:truecolor`;
  4. `TERM` contains `256color` → `:ansi256`;
  5. otherwise → `:ansi16`.
- Can be built with explicit values, for tests.

**`Zat::Style`**

- A `Data` with `fg`, `bg`, `bold`, `italic`, `underline`, `strike` and `dim`.
- `#open(depth)` and `#close` emit the SGR sequences.
- At lower color depths, RGB is downsampled to 256 or 16 colors.

**`Zat::Theme`**

- A frozen map from element → `Style`.

All three are shareable, so they can be sent to the #30 workers.

## Acceptance criteria

- [ ] Color detection tested with a simulated ENV
- [ ] RGB → 256 → 16 conversion tested
- [ ] No ANSI escapes outside `style.rb`
- [ ] `Ractor.shareable?(terminal)` and `Ractor.shareable?(theme)` are both true
