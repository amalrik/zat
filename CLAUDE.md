# Working on Zat

- **Purpose:** a pure-Ruby mdcat clone that doubles as a lab for ZJIT and Ractors on Ruby 4.1. Read [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) first.
- **Decisions are history, not rules.** [docs/decisions.md](docs/decisions.md) explains past reasoning. If evidence contradicts an entry, say so and propose the change. Never resist a better direction because an entry exists; supersede it with a new one.
- **Code is the source of truth.** Don't document contracts or formats in prose; put them in code and tests.
- **Comments are minimal:** only what the code can't reveal (why, gotchas, external constraints, why something is absent).
- **Ractor-safe always:** frozen or shareable constants, no class-level mutable state, no global caches.
- **No runtime dependencies.** Check any candidate gem inside a non-main Ractor first.
- **Everything public is in English:** code, docs, commits, issues, PRs.
- **Every change goes through a PR** linked to its issue; `main` is protected by CI.

```bash
bundle exec rake                          # lint (Standard) + tests
RUBYOPT=--zjit bundle exec rake test      # tests under ZJIT
bundle exec rake test:markdown            # parser in isolation
```
