<!-- title: Tabelas GFM com bordas Unicode -->
<!-- labels: milestone:advanced, area:tables, area:parser, zjit:hot-path, type:feature -->
<!-- milestone: M2 · Experiência avançada -->
## Objetivo

Tabelas GFM completas: parse fiel à spec e layout alinhado com bordas Unicode.

## Regras

**Parser**

- Linha delimitadora com `:--`, `:-:` e `--:`.
- Pipes escapados (`\|`).
- Células a mais ou a menos são ajustadas conforme a spec GFM.
- O conteúdo das células passa pelo parser inline.

**Layout (`Zat::Table`)**

- Bordas `┌─┬─┐ │ ├─┼─┤ └─┴─┘`; o cabeçalho fica em negrito, com o separador `╞═╪═╡`.
- Alinhamento por coluna.
- Cálculo das larguras:
  1. largura natural de cada coluna;
  2. se não couber, encolhe proporcionalmente as colunas mais largas até 6;
  3. o texto quebra dentro da célula;
  4. se ainda não couber, usa o modo registro (`coluna: valor`).
- `ZAT_ASCII=1` troca as bordas por `+-|`.

## Critérios de aceitação

- [ ] Seção de tabelas da spec GFM passa (Z-05)
- [ ] Fixtures: simples, alinhamentos, células vazias, CJK, conteúdo inline, 60 colunas e 30 colunas (modo registro)
- [ ] Nenhuma linha passa de `columns`; as bordas verticais ficam alinhadas
- [ ] Tabela de 1.000 linhas com tempo linear
