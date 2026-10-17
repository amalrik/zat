<!-- title: Terminal, Style e Theme -->
<!-- labels: milestone:mvp, area:terminal, ractor-safety, type:feature -->
<!-- milestone: M1 · MVP -->
## Objetivo

Separar três responsabilidades: o que o terminal suporta (`Terminal`), como um estilo vira bytes (`Style`) e que estilo cada elemento usa (`Theme`).

## Regras

**`Zat::Terminal`**

- Um `Data` resolvido **uma vez**, no Ractor principal, com estes campos:
  - `tty?`;
  - `columns`: via `io/console`; depois `$COLUMNS`; por fim 80;
  - `color_depth`;
  - `hyperlinks?`;
  - `image_protocol`.
- `color_depth` é decidido nesta ordem:
  1. `NO_COLOR` definido → `:none`;
  2. sem TTY e sem `--ansi` → `:none`;
  3. `COLORTERM` igual a `truecolor` ou `24bit` → `:truecolor`;
  4. `TERM` contendo `256color` → `:ansi256`;
  5. caso contrário → `:ansi16`.
- Pode ser construído com valores explícitos, para os testes.

**`Zat::Style`**

- `Data` com `fg`, `bg`, `bold`, `italic`, `underline`, `strike` e `dim`.
- `#open(depth)` e `#close` geram as sequências SGR.
- Quando a profundidade de cor é menor, RGB é convertido para 256 ou 16 cores.

**`Zat::Theme`**

- Mapa congelado de elemento → `Style`.

Todos os três são shareable, para serem enviados aos workers da Z-30.

## Critérios de aceitação

- [ ] Detecção de cor testada com ENV simulado
- [ ] Conversão RGB → 256 → 16 testada
- [ ] Nenhum escape ANSI fora de `style.rb`
- [ ] `Ractor.shareable?(terminal)` e `Ractor.shareable?(theme)` são verdadeiros
