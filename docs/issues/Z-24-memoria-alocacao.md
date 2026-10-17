<!-- title: Métricas de memória e alocação por fase -->
<!-- labels: area:performance, experiment:zjit, type:feature -->
<!-- milestone: Lab · ZJIT -->
## Objetivo

Descobrir se o ZJIT muda o perfil de memória ou só o tempo.

## Regras

- Diferença, por fase, de:
  - `total_allocated_objects`;
  - `malloc_increase_bytes`;
  - quantidade de GC minor e major;
  - `GC.stat(:time)`.
- RSS de pico via `VmHWM`, só no Linux.
- `--trace-alloc` (só para investigação, nunca em medições de tempo) usa `ObjectSpace.trace_object_allocations` e mostra os 20 pontos que mais alocam.
- Duas normalizações: objetos por linha de entrada e bytes alocados por byte de saída.

## Critérios de aceitação

- [ ] Colunas de memória no JSONL da Z-23
- [ ] Os 20 pontos que mais alocam no `mixed-10k`
- [ ] Comparação de objetos por linha entre `interp` e `zjit`. Uma diferença grande já é um achado: o ZJIT pode estar eliminando ou introduzindo alocações
