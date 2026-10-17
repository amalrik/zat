<!-- title: Benchmark corpus generator -->
<!-- labels: area:performance, experiment:zjit, experiment:ractor, type:feature -->
<!-- milestone: Lab · ZJIT -->
## Goal

Benchmark inputs that are reproducible bit for bit, large, and varied in profile.

## Rules

- `bench/corpus/generate.rb --profile P --lines N --seed S` generates a deterministic corpus.
- Profiles:
  - `prose`: long paragraphs with emphasis, links and code spans;
  - `code-heavy`: about 60% code blocks, in several languages;
  - `table-heavy`: tables with 3–12 columns and 5–200 rows, with inline content;
  - `mixed`: proportions of a real-world README;
  - `pathological`: hard cases for the delimiter algorithm and for nesting.
- Sizes: 1k, 10k and 100k lines. For the Ractor lab, also 64 `mixed-1k` files.
- Generated files are not committed. `bench/corpus/MANIFEST` records profile, lines, seed and SHA-256 for each.
- Real-world corpus in `bench/corpus/real/`, downloaded with hash verification: Ruby's `NEWS.md`, a Rails Guide, and mdcat's README.
- The text includes a share of non-ASCII characters.

## Acceptance criteria

- [ ] The same seed produces the same SHA-256
- [ ] `rake bench:corpus` generates the files and validates the MANIFEST
- [ ] Every profile renders without errors under `interp` and `zjit`
- [ ] Per-file statistics recorded
