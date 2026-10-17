<!-- title: CLI: entrada por arquivo e stdin -->
<!-- labels: milestone:mvp, area:cli, type:feature -->
<!-- milestone: M1 · MVP -->
## Objetivo

Criar o `Zat::CLI`: lê os argumentos, abre as entradas e faz uma única escrita por documento.

## Regras

- `zat a.md [b.md…]` renderiza os arquivos em sequência, separados por uma linha em branco. `zat` sem argumentos, ou `zat -`, lê do stdin.
- Entrada em UTF-8; bytes inválidos passam por `scrub`.
- Opções (OptionParser):
  - `-h`, `-V`, `-c/--columns N`;
  - `--no-color`, `--ansi`;
  - `-l/--local`, `--fail`;
  - `-j/--jobs N` (reservada para a Z-30).
- Exit codes: `0` sucesso; `1` algum arquivo falhou (o restante continua, salvo com `--fail`); `2` uso inválido.
- `EPIPE` termina em silêncio, com código 0.

## Critérios de aceitação

- [ ] Arquivo, vários arquivos e stdin funcionam
- [ ] Erros no stderr no formato `zat: <arquivo>: <motivo>`
- [ ] `zat x.md | head -1` não imprime stack trace
- [ ] Testes de integração via `Open3`
