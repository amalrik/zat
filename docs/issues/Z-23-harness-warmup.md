<!-- title: Harness de warm-up in-process -->
<!-- labels: area:performance, experiment:zjit, type:feature -->
<!-- milestone: Lab · ZJIT -->
## Objetivo

Medir a curva de aquecimento do ZJIT, iteração por iteração e fase por fase.

## Regras

- `bench/warmup.rb CORPUS --iterations 200` carrega o arquivo uma vez e, a cada iteração, mede estas fases:
  - `block_parse`;
  - `inline_parse`;
  - `highlight`;
  - `render`;
  - `write` (para `File::NULL`).
- Relógio: `Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)`.
- Os ganchos de fase ficam no próprio código: um `Zat::Instrument` que não faz nada por padrão e custa zero quando desligado (a verificação acontece uma vez, fora dos loops).
- A saída é JSONL, uma linha por iteração.
- `bench/analyze.rb` calcula por fase:
  - a iteração de estabilização (CV < 3% numa janela de 10);
  - o tempo até estabilizar;
  - o custo do warm-up;
  - o break-even contra o `interp`.
- `GC.start` roda só antes da primeira iteração.
- `--parser kramdown` troca o parse pelo kramdown, para comparação.

## Critérios de aceitação

- [ ] JSONL gerado para cada configuração da matriz
- [ ] As quatro métricas calculadas por fase
- [ ] Sparkline da curva no terminal
- [ ] `bench/README.md` explica as métricas
