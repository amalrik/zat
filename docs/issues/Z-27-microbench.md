<!-- title: Microbenchmarks de hot paths -->
<!-- labels: area:performance, experiment:zjit, zjit:hot-path, type:research -->
<!-- milestone: Lab · ZJIT -->
## Objetivo

Isolar padrões de Ruby idiomático e descobrir onde o ZJIT ajuda, onde é neutro e onde atrapalha.

## Microbenchmarks

| Nome | Variantes |
|---|---|
| `scan_style` | Parser de blocos com `StringScanner` + regex × varredura com `getbyte`/`byteindex` |
| `delimiters` | Pilha de delimitadores com `Struct` × `Data` × `Hash` × arrays paralelos |
| `width` | `bsearch` sobre ranges × `case` com ranges literais |
| `wrap` | `each_char` × índice + `getbyte` |
| `buffer` | `<<` × interpolação × `Array#join` × `StringIO` |
| `dispatch` | `case/when` × `send(:"render_#{t}")` × Hash de lambdas × uma classe por tipo de nó |
| `sgr` | Montar na hora × cache congelado |
| `kramdown_parse` | Controle negativo: o ganho deve ser baixo porque o tempo está em regex |

## Regras

- Usa o mesmo harness da Z-23, que mede a curva, não só a média.
- Todas as variantes de um microbenchmark precisam produzir o mesmo resultado, e isso é verificado.
- Para cada microbenchmark, o relatório registra a conclusão (ajuda, neutro ou atrapalha) e o motivo, com as stats da Z-25.
- Uma variante só entra no código de produto se for melhor sob ZJIT **e** tão legível quanto a atual.

## Critérios de aceitação

- [ ] Os 8 microbenchmarks implementados e com verificação de resultado
- [ ] O controle negativo mostra ganho baixo; se não mostrar, o método de medição é investigado
- [ ] Conclusões registradas em `docs/zjit-findings.md`
