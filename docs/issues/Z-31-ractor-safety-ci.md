<!-- title: Ractor-safety enforced in CI -->
<!-- labels: area:tests, ractor-safety, experiment:ractor, type:chore -->
<!-- milestone: Lab · Ractors -->
## Goal

Keep any code from quietly starting to depend on global state. This guard lands **during M1**, not later.

## Rules

- A `test/ractor_safety_test.rb` test that:
  1. runs the full pipeline (parse, render, highlighting and tables) inside `Ractor.new` over every golden fixture;
  2. compares the result with the main-Ractor output;
  3. checks `Ractor.shareable?` on every constant under `Zat::` (walking `constants` recursively).
- A simple lint (`rake check:ractor`) that looks for writes to class-level instance variables (`@x ||=` inside `self.`/`class << self`) in `lib/`.
- Runs in CI with and without `--zjit`.

## Acceptance criteria

- [ ] The test passes, and fails on purpose when someone adds a cache in a class-level instance variable (a test of the test)
- [ ] The lint is part of `rake test`
- [ ] Documented in `CONTRIBUTING.md`
