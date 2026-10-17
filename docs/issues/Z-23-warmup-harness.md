<!-- title: In-process warm-up harness -->
<!-- labels: area:performance, experiment:zjit, type:feature -->
<!-- milestone: Lab · ZJIT -->
## Goal

Measure the ZJIT warm-up curve iteration by iteration and phase by phase.

## Rules

- `bench/warmup.rb CORPUS --iterations 200` loads the file once and, on each iteration, times these phases:
  - `block_parse`;
  - `inline_parse`;
  - `highlight`;
  - `render`;
  - `write` (to `File::NULL`).
- Clock: `Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)`.
- Phase hooks live in the code itself: a `Zat::Instrument` that does nothing by default and costs nothing when off (checked once, outside the loops).
- Output is JSONL, one line per iteration.
- `bench/analyze.rb` computes, per phase:
  - the stabilization iteration (CV < 3% over a window of 10);
  - the time to stabilize;
  - the warm-up cost;
  - the break-even point against `interp`.
- `GC.start` runs only before the first iteration.
- `--parser kramdown` swaps the parse phase for kramdown, for comparison.
- Optional: `RubyVM::ZJIT.reset_stats!` after stabilizing, to collect steady-state-only stats. `--zjit-trace-compiles` produces a Perfetto trace of the warm-up.

## Acceptance criteria

- [ ] JSONL produced for every matrix configuration
- [ ] The four metrics computed per phase
- [ ] A terminal sparkline of the curve
- [ ] `bench/README.md` explains the metrics
