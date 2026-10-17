<!-- title: Toolchain: Ruby 4.1 with ZJIT -->
<!-- labels: milestone:setup, area:infra, experiment:zjit, type:chore -->
<!-- milestone: M0 · Foundation -->
## Goal

Have Ruby 4.1 **built with ZJIT**, reproducible by anyone who clones the repository.

## Context

- Ruby binaries that version managers download prebuilt usually ship YJIT only (`--enable-yjit`). ZJIT is written in Rust and is only included when `rustc` is visible at `configure` time.
- `4.1.0-preview1` and `4.1-dev` are available through mise. The RC usually lands around December; switch to it when it does.

## Rules

- Version pinned in `mise.toml`, with the exact Ruby commit recorded in `docs/toolchain.md`.
- The build must also include YJIT, which is the reference column.
- No exotic build flags.
- Every Ruby version bump produces a new benchmark baseline (#26).

## Acceptance criteria

- [ ] `rustc` installed; version recorded
- [ ] Ruby 4.1 installed via mise with ZJIT; steps in `docs/toolchain.md`
- [ ] `ruby --zjit -e 'p RubyVM::ZJIT.enabled?'` prints `true`
- [ ] `ruby --yjit -e 'p RubyVM::YJIT.enabled?'` prints `true`
- [ ] Actual `--zjit-*` flags from `ruby --help` recorded in `docs/toolchain.md`
- [ ] API recorded: `RubyVM::ZJIT.methods(false)` and the stats format
- [ ] Ractors: 4.1 API confirmed (`Ractor#value`, `Ractor::Port`, `Ractor.make_shareable`) and whether the "experimental" warning is still emitted
