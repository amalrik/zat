<!-- title: Imagens via Kitty graphics protocol -->
<!-- labels: milestone:protocols, area:images, type:feature -->
<!-- milestone: M3 · Protocolos modernos -->
## Objetivo

Mostrar imagens PNG locais inline em terminais compatíveis com o protocolo gráfico do Kitty.

## Regras

- Só PNG, reconhecido pela assinatura `\x89PNG\r\n\x1a\n` e enviado com `f=100`. Quem decodifica é o terminal.
- O conteúdo vai em base64 com `[bytes].pack("m0")` (funciona em Ractor), dividido em blocos de 4096 bytes:
  - `\e_Ga=T,f=100,q=2,c=<cols>,m=1;<bloco>\e\\` em cada bloco, menos o último;
  - `\e_Gm=0;<bloco>\e\\` no último.
- A largura e a altura vêm do IHDR (bytes 16–23). `c=` limita a imagem a `columns`, preservando a proporção.
- Uma quebra de linha depois da imagem.

## Critérios de aceitação

- [ ] Golden test com um PNG pequeno em `test/fixtures/img/`
- [ ] Um PNG de 2 MB gera o número correto de blocos
- [ ] Imagens que não são PNG vão para o fallback (Z-21)
- [ ] Teste manual no Kitty e no Ghostty, com captura de tela no PR
