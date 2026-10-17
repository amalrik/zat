<!-- title: Imagens via iTerm2 inline images -->
<!-- labels: milestone:protocols, area:images, type:feature -->
<!-- milestone: M3 · Protocolos modernos -->
## Objetivo

Mostrar imagens locais inline no iTerm2 e no WezTerm via OSC 1337.

## Regras

- Sequência: `\e]1337;File=name=<b64 nome>;size=<bytes>;inline=1;width=<N>;preserveAspectRatio=1:<b64 arquivo>\a`.
- Formatos aceitos: PNG, JPEG e GIF, identificados pelos magic bytes. O Zat não decodifica imagens.
- `width` é limitado a `columns`.

## Critérios de aceitação

- [ ] Golden tests com PNG e JPEG
- [ ] Nomes de arquivo com caracteres não-ASCII funcionam
- [ ] Teste manual documentado no PR
