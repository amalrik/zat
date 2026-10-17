<!-- title: Comparative runner -->
<!-- labels: area:performance, experiment:zjit, area:infra, type:feature -->
<!-- milestone: Lab · ZJIT -->
## Goal

A single command that runs the full matrix and produces tables ready to publish.

## Rules

- `rake bench` runs configuration × corpus × mode:
  - configurations: `interp`, `zjit`, `zjit-t1`, and `yjit` as a reference;
  - modes: `cold`, `warm` and `batch`.
- The matrix lives in `bench/config.rb`, the only place with JIT flags.
- **`cold` mode:**
  - a fresh process per run;
  - N=30, with 3 discarded runs;
  - uses `hyperfine --export-json` when installed, otherwise `Process.spawn`.
- **`warm` mode:** uses the #23 harness. **`batch` mode:** `zat corpus/*.md` in a single process.
- **Parser comparison:** Zat vs kramdown on the same corpus and matrix.
- **Statistics:** median, p95, stddev, and speedup over `interp` with a bootstrap 95% CI (fixed seed).
- `env.json` records:
  - `ruby -v` and the Ruby commit;
  - CPU, governor and kernel;
  - the Zat commit.
- Warns on stderr if the governor isn't `performance` or if `loadavg` is above 1.
- **Output:** `bench/results/<YYYY-MM-DD>-<ruby-commit>/` with `raw.jsonl`, `summary.csv`, `REPORT.md` and `env.json`.
- `rake bench:quick`: a ~1-minute subset for PRs labeled `zjit:hot-path`.

## Acceptance criteria

- [ ] Runs end to end without hyperfine
- [ ] `REPORT.md` with Markdown tables (renderable by `zat` itself)
- [ ] Two consecutive runs give medians within ±5%, or the reason is documented
- [ ] CI runs `bench:quick` as a smoke test only; its numbers are not published
