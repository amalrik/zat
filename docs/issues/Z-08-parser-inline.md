<!-- title: Parser inline -->
<!-- labels: milestone:mvp, area:parser, gem:markdown, zjit:hot-path, ractor-safety, type:feature -->
<!-- milestone: M1 · MVP -->
## Objetivo

Segunda fase do `Zat::Markdown`: transformar o texto cru de parágrafos, headings e células em nós inline.

## Escopo

- Escapes com backslash e entidades (tabela própria congelada em `entities.rb`, gerada a partir da lista oficial do HTML5).
- Code spans.
- Ênfase e negrito pelo algoritmo de *delimiter stack* da spec (`*` e `_`, regras de left/right-flanking).
- Strikethrough GFM (`~~`).
- Links e imagens inline: `[t](url "título")` e `![alt](src)`.
- Autolinks `<…>` e autolinks estendidos GFM (`www.`, `http(s)://`).
- Quebra de linha forçada e quebra suave.

## Regras

- O algoritmo de delimitadores é implementado de forma direta e legível. Ele é o principal hot path do parser e o alvo da Z-27.
- Nenhuma alocação de substring por caractere: trabalhar com índices de byte e cortar só ao emitir os nós de texto.
- Texto adjacente é agregado num único nó `:text`.

## Critérios de aceitação

- [ ] As seções inline da spec dentro do subconjunto passam (Z-05)
- [ ] Teste patológico: `*` × 10.000 e colchetes aninhados não ficam quadráticos (casos da spec)
- [ ] Teste diferencial contra o kramdown sem divergências não documentadas
- [ ] Funciona dentro de um Ractor
