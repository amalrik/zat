<!-- title: Renderer: blocos e inline básicos -->
<!-- labels: milestone:mvp, area:renderer, zjit:hot-path, type:feature -->
<!-- milestone: M1 · MVP -->
## Objetivo

Criar o `Zat::Renderer`: percorre a AST do `Zat::Markdown` e escreve num único buffer.

## Elementos

- **Blocos:**
  - headings h1–h6 (h1 e h2 destacados, com `━` e `─`);
  - parágrafo;
  - citação com `│` (aninhável);
  - regra horizontal;
  - código, provisoriamente sem realce (o realce vem na Z-15);
  - `:html_block` em texto esmaecido.
- **Inline:** negrito, itálico, os dois combinados, code span, strikethrough, quebras de linha e HTML inline esmaecido.

## Regras

- Buffer único: `String.new(capacity: source.bytesize * 2)` com `<<`.
- Despacho com `case node.type`.
- Pilha de estilos: ao fechar um estilo interno, o externo é reaberto.
- Sem estado global; o renderer é uma instância por documento.

## Critérios de aceitação

- [ ] Fixture golden para cada elemento e para os aninhamentos
- [ ] `:none` gera texto puro, sem escapes residuais
- [ ] Renderiza sem erro o `README.md` do mdcat e o `NEWS.md` do Ruby
- [ ] O render roda dentro de um Ractor
