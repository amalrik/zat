<!-- title: Parser de blocos -->
<!-- labels: milestone:mvp, area:parser, gem:markdown, zjit:hot-path, ractor-safety, type:feature -->
<!-- milestone: M1 · MVP -->
## Objetivo

Primeira fase do `Zat::Markdown`: transformar o texto numa árvore de blocos, seguindo a estratégia da spec do CommonMark (container blocks abertos + leaf block atual, linha a linha).

## Escopo

- Headings ATX e setext; parágrafos; thematic break.
- Block quote, aninhado.
- Listas: marcadores, números iniciais, tight/loose, aninhamento por indentação.
- Fenced code (` ``` ` e `~~~`, info string, cerca de fechamento de tamanho ≥ ao da abertura).
- Indented code; linhas em branco.
- Tabelas GFM: só detecta e separa as células (o layout vem na Z-14).
- Blocos HTML: um único nó `:html_block` com o texto cru.

## Regras

- Entrada: `String` UTF-8. Normaliza `\r\n` e expande tabs para colunas de 4 na indentação, como manda a spec.
- O texto inline (conteúdo de parágrafos e headings) **fica cru** no nó, para a Z-08 processar.
- Linear no tamanho da entrada: nenhum backtracking entre linhas.
- Nós `Data.define` imutáveis. O resultado passa em `Ractor.shareable?` depois de `make_shareable`.
- Posição de origem (linha) em cada bloco, para mensagens de erro e futuros recursos.

## Critérios de aceitação

- [ ] As seções de blocos da spec passam (Z-05)
- [ ] Documento de 100k linhas parseado em tempo linear (teste de sanidade: 10k × 100k)
- [ ] `Ractor.new { Zat::Markdown.parse(src) }.value` funciona
- [ ] Nenhum `require` de código fora de `zat/markdown`
