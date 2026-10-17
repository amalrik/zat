<!-- title: Detecção de protocolo de imagem -->
<!-- labels: milestone:protocols, area:images, area:terminal, type:feature -->
<!-- milestone: M3 · Protocolos modernos -->
## Objetivo

Descobrir, de forma conservadora, se o terminal suporta imagens inline e por qual protocolo.

## Regras

- `Terminal#image_protocol` vale `:kitty`, `:iterm2` ou `nil`, decidido nesta ordem:
  1. `KITTY_WINDOW_ID` ou `TERM=xterm-kitty` → `:kitty`;
  2. `TERM_PROGRAM=ghostty` → `:kitty`;
  3. `TERM_PROGRAM=WezTerm` → `:iterm2`;
  4. `TERM_PROGRAM=iTerm.app` ou `LC_TERMINAL=iTerm2` → `:iterm2`;
  5. caso contrário → `nil`.
- Em `tmux` ou `screen`: `nil`, a menos que `ZAT_IMAGES=kitty|iterm2|off` force outro valor.
- Nunca consultar o terminal com escapes de pergunta e resposta.

## Critérios de aceitação

- [ ] Tabela de detecção testada com ENV simulado
- [ ] `ZAT_IMAGES` documentado no `--help`
- [ ] Sem TTY, o resultado é sempre `nil`
