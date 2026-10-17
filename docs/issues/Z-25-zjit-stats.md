<!-- title: ZJIT stats collection -->
<!-- labels: area:performance, experiment:zjit, type:feature -->
<!-- milestone: Lab · ZJIT -->
## Goal

Record what ZJIT did: what it compiled, how long it took, and where execution left compiled code.

## Rules

- A dedicated run with `--zjit-stats=stats-zjit.json` (JSON output is native) or `--zjit-stats-quiet` + `RubyVM::ZJIT.stats`, always separate from timed runs.
- Metrics of particular interest (key names from `docs/toolchain.md`):
  - `compile_time_ns` and the `compile_hir_*` / `compile_lir_time_ns` phases;
  - `compiled_iseq_count` and `failed_iseq_count`;
  - `side_exit_count` and the `exit_*` counters by reason;
  - `send_fallback_*` and `unspecialized_send_*` (calls ZJIT didn't specialize);
  - `unhandled_yarv_*` (unsupported instructions);
  - `code_region_bytes` and `total_mem_bytes`.
- `--zjit-trace-exits` maps side exits back to Ruby source locations.
- `--zjit-call-threshold` variations: 1, default (30) and high.
- `--yjit-stats` only for the equivalent metrics in the reference table.

## Acceptance criteria

- [ ] `rake bench:stats[corpus]` produces `stats-zjit.json`
- [ ] Top 10 side-exit reasons on `mixed-10k`, each mapped to the Zat Ruby method that causes it
- [ ] For each of those 10: a known ZJIT limitation, a code pattern of ours worth changing, or a candidate to report upstream?
