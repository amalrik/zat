<!-- title: Findings report and upstream feedback template -->
<!-- labels: area:performance, experiment:zjit, experiment:ractor, type:chore -->
<!-- milestone: Lab · ZJIT -->
## Goal

Turn results into reproducible reports that are useful to Ruby maintainers (ZJIT and Ractors).

## Rules

- `docs/zjit-findings.md` is the cumulative log of findings, in chronological order.
- Template in `.github/ISSUE_TEMPLATE/finding.md`:

  ```markdown
  ### Summary
  <one sentence: what happens, under which configuration (ZJIT / Ractor)>

  ### Environment
  - ruby -v / commit:
  - CPU / governor / kernel:
  - Zat commit:

  ### Reproduction
  1. corpus (seed, SHA-256):
  2. exact command:

  ### Result
  | config | median | p95 | speedup vs interp |
  |---|---|---|---|

  ### Stats
  <excerpt from --zjit-stats or per-Ractor GC.stat>

  ### Hypothesis
  <kept separate from the facts above>

  ### Minimal reproduction
  <a small script independent of Zat>
  ```

- A finding goes upstream only when:
  1. it reproduces in two runs, on different days or different machines;
  2. there is a minimal reproduction outside Zat;
  3. there is no equivalent open issue in Ruby's tracker.
- Each finding is classified: `crash/miscompile` > `regression` > `slower than YJIT` > `observation`.

## Acceptance criteria

- [ ] Template created
- [ ] First baseline report (M1 complete × matrix) published in `docs/zjit-findings.md`
- [ ] Process described in `bench/README.md`
