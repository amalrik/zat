<!-- title: Runner comparativo -->
<!-- labels: area:performance, experiment:zjit, area:infra, type:feature -->
<!-- milestone: Lab · ZJIT -->
## Objetivo

Um único comando roda a matriz completa e gera tabelas prontas para publicar.

## Regras

- `rake bench` roda configuração × corpus × modo:
  - configurações: `interp`, `zjit`, `zjit-t1` e `yjit` (esta como referência);
  - modos: `cold`, `warm` e `batch`.
- A matriz fica em `bench/config.rb`, o único lugar com flags de JIT.
- **Modo `cold`:**
  - um processo novo por execução;
  - N=30, com 3 execuções descartadas;
  - usa `hyperfine --export-json` se estiver instalado; senão, `Process.spawn`.
- **Modo `warm`:** usa o harness da Z-23. **Modo `batch`:** `zat corpus/*.md` em um único processo.
- **Comparação de parsers:** Zat × kramdown com o mesmo corpus e a mesma matriz.
- **Estatística:** mediana, p95, desvio e ganho sobre o `interp`, com IC 95% por bootstrap (semente fixa).
- `env.json` registra:
  - `ruby -v` e o commit do Ruby;
  - CPU, governor e kernel;
  - o commit do Zat.
- Avisa no stderr se o governor não for `performance` ou se `loadavg` passar de 1.
- **Saída:** `bench/results/<AAAA-MM-DD>-<ruby-commit>/` com `raw.jsonl`, `summary.csv`, `REPORT.md` e `env.json`.
- `rake bench:quick` roda um subconjunto de cerca de 1 minuto, usado nos PRs com o label `zjit:hot-path`.

## Critérios de aceitação

- [ ] Roda de ponta a ponta sem o hyperfine
- [ ] `REPORT.md` com tabelas Markdown (que o próprio `zat` consegue renderizar)
- [ ] Duas rodadas seguidas dão medianas dentro de ±5%, ou o motivo fica documentado
- [ ] O CI roda `bench:quick` só como smoke test, sem publicar os números
