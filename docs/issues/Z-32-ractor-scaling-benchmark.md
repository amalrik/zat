<!-- title: Ractor scaling and contention benchmark -->
<!-- labels: area:performance, experiment:ractor, experiment:zjit, type:research -->
<!-- milestone: Lab · Ractors -->
## Goal

Measure how Zat scales with Ractors on Ruby 4.1, and how that interacts with ZJIT.

## Context

A quick preliminary run of pure-Ruby ANSI string building, 4 tasks:

| Ruby | Speedup with 4 Ractors |
|---|---|
| 4.0.7 | ~1.9x on a 16-core machine (initial hypothesis: allocation/GC contention) |
| 4.1.0-preview1 | 3.6x (interp), 4.0x (yjit), 3.9x (zjit) |

The hypothesis did **not** reproduce on 4.1 for that workload. The lab now checks whether it holds for the real one. See `docs/toolchain.md`.

## Scenarios

| Scenario | Variables |
|---|---|
| Scaling | `--jobs` ∈ {1, 2, 4, 8, 16} × {`interp`, `zjit`} × 64 `mixed-1k` files |
| Allocation | Allocation-heavy (`table-heavy`) vs allocation-light (`prose`) profiles, to separate CPU from allocation |
| ZJIT × Ractors | Is compiled code reused across Ractors, or is warm-up repeated in each worker? |
| Communication | Path vs content; copy vs `move: true` (#30) |

## Metrics

- Total time, speedup, and efficiency (speedup / N).
- Global `GC.stat` and GC time during the batch.
- Per-core CPU usage (`/proc/self/stat`).
- Comparison with separate processes (`xargs -P N zat`), an upper bound without Ractors.

## Acceptance criteria

- [ ] Scaling curve in `REPORT.md` (table and sparkline)
- [ ] Ractors vs processes comparison
- [ ] If efficiency is below 50% at 4 jobs: a minimal reproduction outside Zat and a recorded finding (#29)
