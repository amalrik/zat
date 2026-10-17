<!-- title: Listas e task lists -->
<!-- labels: milestone:mvp, area:parser, area:renderer, type:feature -->
<!-- milestone: M1 · MVP -->
## Objetivo

Renderizar listas ordenadas e não ordenadas, aninhadas, e task lists, com a indentação certa quando uma linha quebra.

## Regras

- **Parser:**
  - `[ ]` e `[x]` no início do primeiro parágrafo de um item viram o atributo `task: :open` ou `task: :done`.
  - Isso vale só para listas, como no GFM.
- **Renderer:**
  - Marcadores por nível: `•` `◦` `▪` (o ciclo se repete).
  - Listas ordenadas respeitam o número inicial; os números ficam alinhados à direita.
  - Task lists usam `☐` e `☑`; itens concluídos ficam esmaecidos.
  - A continuação de uma linha quebrada alinha com o texto, não com o marcador.
  - Listas loose têm linha em branco entre os itens; listas tight, não.
  - Blocos dentro de um item herdam a indentação.

## Critérios de aceitação

- [ ] Fixtures: tight, loose, quatro níveis, lista começando em 7, lista mista e task list
- [ ] Item longo quebrado em 40 colunas
- [ ] Bloco de código dentro de um item
