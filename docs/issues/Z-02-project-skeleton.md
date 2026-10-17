<!-- title: Project skeleton, Gemfile and CI -->
<!-- labels: milestone:setup, area:infra, type:chore -->
<!-- milestone: M0 · Foundation -->
## Goal

Minimal project structure: executable, library, tests, Rake and CI.

## Structure

```
exe/zat
lib/zat.rb  lib/zat/version.rb  lib/zat/markdown.rb
test/test_helper.rb  test/markdown/  test/zat/
Gemfile  zat.gemspec  Rakefile  mise.toml
.github/workflows/ci.yml
```

## Rules

- **Zero runtime dependencies.** Everything comes from the standard library and default gems (Prism included).
- Development dependencies: `minitest`, `rake`, and `kramdown` + `kramdown-parser-gfm` (differential tests and comparisons only).
- `# frozen_string_literal: true` in every file.
- `test/markdown/` only tests `Zat::Markdown`, without loading the rest of Zat. This prepares the gem extraction.

## Acceptance criteria

- [ ] `exe/zat --version` works
- [ ] `rake test` passes
- [ ] `rake test:markdown` runs in isolation (`require "zat/markdown"` without loading `zat`)
- [ ] CI matrix: Ruby 4.1 × `RUBYOPT` ∈ {empty, `--zjit`, `--zjit --zjit-call-threshold=1`}
- [ ] The gemspec has no `add_dependency`, and a test enforces it
- [ ] Minimal README
