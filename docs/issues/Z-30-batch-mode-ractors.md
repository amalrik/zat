<!-- title: Batch mode with Ractors (--jobs) -->
<!-- labels: area:cli, experiment:ractor, ractor-safety, type:feature -->
<!-- milestone: Lab · Ractors -->
## Goal

`zat docs/**/*.md --jobs N` renders many files in parallel using Ractors, keeping output order.

## Rules

- `Zat::Batch`:
  - the main Ractor resolves `Terminal` and `Theme` (shareable);
  - N workers receive file paths;
  - each worker reads, parses, renders, and returns the string;
  - the main Ractor writes the outputs in argument order.
- `--jobs` defaults to the processor count, and only applies when there's more than one file. `--jobs 1` uses no Ractors at all.
- Images: workers only build the escape sequences; the main Ractor always does the writing.
- An error in one file doesn't bring down the others and is reported on stderr.
- Two communication strategies, both implemented for comparison (#32):
  - send the path and read in the worker, or send the content;
  - return output by copy or with `move: true`.
- Uses the 4.1 Ractor API confirmed in #1 (`Ractor::Port`, `#value`, `#join`).

## Acceptance criteria

- [ ] The output of `--jobs 8` is byte-identical to `--jobs 1`
- [ ] Works under `--zjit`
- [ ] A failing file in the middle of a batch: the others still render and the exit code is 1
- [ ] The "Ractor API is experimental" warning (still present in 4.1.0-preview1) is suppressed, with the reason documented
