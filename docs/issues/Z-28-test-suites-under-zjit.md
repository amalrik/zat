<!-- title: Third-party test suites under --zjit -->
<!-- labels: area:tests, experiment:zjit, type:research -->
<!-- milestone: Lab · ZJIT -->
## Goal

Use existing test suites as a detector for ZJIT miscompilations. It's the most valuable kind of feedback for a young JIT, and it costs almost nothing.

## Rules

- `script/zjit_suites.sh` clones pinned versions of kramdown, Rouge and `unicode-display_width` and runs each test suite with:
  1. the interpreter;
  2. `--zjit`;
  3. `--zjit --zjit-call-threshold=1` (compiles everything, maximizing JIT coverage).
- A failure that only shows up under ZJIT is investigated until it becomes a minimal reproduction.
- Zat's own suite already runs under `--zjit` in CI (#2); this issue covers third-party gems.
- Bonus: record the Ractor failures found in these gems (`Ractor::IsolationError`) and, where it makes sense, open an issue in each gem's repository, citing Ruby 4.1.

## Acceptance criteria

- [ ] The script runs all three suites in all three modes and saves a summary to `bench/results/suites-<date>.md`
- [ ] Every ZJIT-only failure recorded as a finding (#29)
- [ ] Re-run on every new Ruby 4.1 release (preview, RC, final)
