<!-- title: Largura de exibição e quebra de linha -->
<!-- labels: milestone:mvp, area:text, zjit:hot-path, experiment:zjit, ractor-safety, type:feature -->
<!-- milestone: M1 · MVP -->
## Objetivo

- `Zat::Width`: largura de exibição sem dependências externas e segura em Ractor.
- `Zat::Text`: quebra de linha que entende escapes ANSI.

## Contexto

A gem `unicode-display_width` falha em Ractor (`EmojiSupport.recommended` grava uma variável de instância de classe). Por isso a tabela é nossa.

## Regras

- **`Zat::Width`:**
  - A tabela de ranges (largura 0, 1 ou 2) é gerada por `script/gen_width_table.rb` a partir de `EastAsianWidth.txt` e `emoji-data.txt` do Unicode. A versão do Unicode acompanha a do Ruby 4.1.
  - O resultado é um array congelado de inteiros, consultado com `bsearch`.
  - Atalho rápido para `ascii_only?`.
  - Clusters de emoji com ZWJ contam como 2.
- **`Text.width(str)`:** ignora SGR e OSC 8.
- **`Text.wrap(str, width, indent:)`:**
  - quebra nos espaços;
  - corta palavras maiores que a largura;
  - fecha e reabre os estilos ativos em cada quebra.

## Critérios de aceitação

- [ ] Testes com acentos, CJK, emoji com ZWJ e escapes no meio de uma palavra
- [ ] Teste de propriedade com semente: nenhuma linha passa de `columns`
- [ ] Os estilos sobrevivem à quebra
- [ ] A tabela é shareable e a versão do Unicode está documentada
