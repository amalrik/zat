<!-- title: Image protocol detection -->
<!-- labels: milestone:protocols, area:images, area:terminal, type:feature -->
<!-- milestone: M3 · Modern protocols -->
## Goal

Conservatively detect whether the terminal supports inline images, and through which protocol.

## Rules

- `Terminal#image_protocol` is `:kitty`, `:iterm2` or `nil`, decided in this order:
  1. `KITTY_WINDOW_ID` or `TERM=xterm-kitty` → `:kitty`;
  2. `TERM_PROGRAM=ghostty` → `:kitty`;
  3. `TERM_PROGRAM=WezTerm` → `:iterm2`;
  4. `TERM_PROGRAM=iTerm.app` or `LC_TERMINAL=iTerm2` → `:iterm2`;
  5. otherwise → `nil`.
- Under `tmux` or `screen`: `nil`, unless `ZAT_IMAGES=kitty|iterm2|off` forces another value.
- Never query the terminal with request/response escapes.

## Acceptance criteria

- [ ] Detection table tested with a simulated ENV
- [ ] `ZAT_IMAGES` documented in `--help`
- [ ] Without a TTY, the result is always `nil`
