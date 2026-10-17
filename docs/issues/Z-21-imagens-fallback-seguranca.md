<!-- title: Imagens: fallback e segurança -->
<!-- labels: milestone:protocols, area:images, type:feature -->
<!-- milestone: M3 · Protocolos modernos -->
## Objetivo

Garantir que imagens nunca quebrem a saída, nunca acessem a rede e nunca leiam arquivos inesperados.

## Regras

- Caminhos relativos são resolvidos a partir do diretório do `.md`; para stdin, a partir do diretório atual.
- URLs `http(s)://` não são baixadas e vão direto para o fallback.
- Limite padrão de 10 MB, ajustável com `--max-image-size`.
- Fallback: `🖼 alt (caminho)` com estilo, ou `[imagem: alt]` quando não há cor.
- Com `--local`, só são aceitos arquivos dentro do diretório do documento. Symlinks que saem desse diretório são recusados.

## Critérios de aceitação

- [ ] Testes para arquivo inexistente, grande demais, remoto, fora do diretório com `--local` e com formato errado
- [ ] Nenhum erro de imagem interrompe o restante do documento
- [ ] Comportamento documentado no README
