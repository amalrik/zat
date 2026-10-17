<!-- title: Benchmark de escala e contenção de Ractors -->
<!-- labels: area:performance, experiment:ractor, experiment:zjit, type:research -->
<!-- milestone: Lab · Ractors -->
## Objetivo

Medir como o Zat escala com Ractors no Ruby 4.1 e como isso interage com o ZJIT.

## Contexto

Uma medição preliminar (Ruby 4.0.7, montagem de strings ANSI) mostrou só ~1,9x de ganho com 4 Ractors numa máquina de 16 núcleos. A hipótese é contenção na alocação ou no GC.

## Cenários

| Cenário | Variáveis |
|---|---|
| Escala | `--jobs` ∈ {1, 2, 4, 8, 16} × {`interp`, `zjit`} × 64 arquivos `mixed-1k` |
| Alocação | Perfis com mais alocação (`table-heavy`) e menos (`prose`), para separar CPU de alocação |
| ZJIT × Ractors | O código compilado é aproveitado entre Ractors? O warm-up se repete em cada worker? |
| Comunicação | Caminho × conteúdo; cópia × `move: true` (Z-30) |

## Métricas

- Tempo total, ganho e eficiência (ganho / N).
- `GC.stat` global e tempo de GC durante o lote.
- Uso de CPU por núcleo (`/proc/self/stat`).
- Comparação com processos separados (`xargs -P N zat`), um limite superior sem Ractor.

## Critérios de aceitação

- [ ] Curva de escala no `REPORT.md` (tabela e sparkline)
- [ ] Comparação Ractors × processos
- [ ] Se a eficiência ficar abaixo de 50% com 4 jobs: reprodução mínima fora do Zat e achado registrado (Z-29)
