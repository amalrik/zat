<!-- title: Modo em lote com Ractors (--jobs) -->
<!-- labels: area:cli, experiment:ractor, ractor-safety, type:feature -->
<!-- milestone: Lab · Ractors -->
## Objetivo

`zat docs/**/*.md --jobs N` renderiza muitos arquivos em paralelo usando Ractors, mantendo a ordem da saída.

## Regras

- `Zat::Batch`:
  - o Ractor principal resolve `Terminal` e `Theme` (shareable);
  - N workers recebem os caminhos dos arquivos;
  - cada worker lê, parseia, renderiza e devolve a string;
  - o principal escreve as saídas na ordem dos argumentos.
- `--jobs` vale por padrão o número de processadores, e só se houver mais de um arquivo. `--jobs 1` não usa Ractor nenhum.
- Imagens: os workers só preparam a sequência de escape; quem escreve é sempre o Ractor principal.
- Um erro num arquivo não derruba os outros e é reportado no stderr.
- Duas estratégias de comunicação, ambas implementadas para comparação (Z-32):
  - enviar o caminho, com leitura no worker, ou enviar o conteúdo;
  - devolver a saída por cópia ou com `move: true`.
- Usar a API de Ractor do 4.1 confirmada na Z-01 (`Ractor::Port`, `#value`).

## Critérios de aceitação

- [ ] A saída de `--jobs 8` é byte a byte idêntica à de `--jobs 1`
- [ ] Funciona com `--zjit`
- [ ] Arquivo com erro no meio do lote: os demais são renderizados e o exit code é 1
- [ ] O aviso de "experimental", se ainda existir no 4.1, é suprimido e o motivo fica documentado
