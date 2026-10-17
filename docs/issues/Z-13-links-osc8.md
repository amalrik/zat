<!-- title: Links com OSC 8 e fallback -->
<!-- labels: milestone:mvp, area:renderer, area:terminal, type:feature -->
<!-- milestone: M1 · MVP -->
## Objetivo

Links clicáveis nos terminais que suportam OSC 8, e legíveis nos demais.

## Regras

- **Com OSC 8:** o link sai como `\e]8;;URL\e\\texto\e]8;;\e\\`, no estilo `link`.
- **Sem OSC 8:** o texto sai como `texto[1]`, e uma seção "Links" no fim do documento lista as URLs.
- Autolinks, e links cujo texto é a própria URL, não ganham referência numerada.
- Âncoras (`#secao`) aparecem só como texto.
- O suporte a OSC 8 é detectado por `TERM_PROGRAM` e `TERM`, usando uma lista conservadora.

## Critérios de aceitação

- [ ] Fixtures com OSC 8 e com o fallback
- [ ] URLs com caracteres especiais saem corretas
- [ ] O wrap (Z-12) nunca quebra uma sequência OSC 8 ao meio
