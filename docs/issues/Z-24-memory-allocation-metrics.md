<!-- title: Per-phase memory and allocation metrics -->
<!-- labels: area:performance, experiment:zjit, type:feature -->
<!-- milestone: Lab · ZJIT -->
## Goal

Find out whether ZJIT changes the memory profile or only the timing.

## Rules

- Per-phase deltas of:
  - `total_allocated_objects`;
  - `malloc_increase_bytes`;
  - minor and major GC counts;
  - `GC.stat(:time)`.
- Peak RSS from `VmHWM`, Linux only.
- `--trace-alloc` (investigation only, never in timed runs) uses `ObjectSpace.trace_object_allocations` and lists the 20 sites that allocate the most.
- Two normalizations: objects per input line, and bytes allocated per output byte.

## Acceptance criteria

- [ ] Memory columns in the #23 JSONL
- [ ] Top 20 allocation sites for `mixed-10k`
- [ ] Objects-per-line comparison between `interp` and `zjit`. A large difference is a finding in itself: ZJIT may be removing or adding allocations
