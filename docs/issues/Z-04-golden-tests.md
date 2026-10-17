<!-- title: Testes golden de saída ANSI -->
<!-- labels: milestone:setup, area:tests, type:chore -->
<!-- milestone: M0 · Fundação -->
## Objetivo

Regressão visual: cada fixture `.md` tem uma saída esperada `.ansi`, comparada byte a byte.

## Regras

- Fixtures em `test/fixtures/<nome>.md`; saídas em `test/fixtures/<nome>.<cols>.ansi`.
- `Terminal` fixo nos testes: 80 colunas, TrueColor, OSC 8 ligado e sem imagens. O ambiente real nunca vaza.
- `ZAT_UPDATE_GOLDEN=1 rake test` regrava as saídas esperadas.
- O diff mostra os escapes de forma legível (`\e[1m`).

## Critérios de aceitação

- [ ] Helper `assert_golden(name, columns: 80)`
- [ ] Modo de atualização
- [ ] Diff legível
- [ ] `rake golden:show[nome]` para inspeção visual
- [ ] Os goldens passam também sob `--zjit` no CI. Uma diferença ali é um bug de compilação candidato a reporte (Z-28)
