<!-- title: Syntax highlighting: Prism + own highlighter -->
<!-- labels: milestone:advanced, area:syntax, zjit:hot-path, experiment:zjit, ractor-safety, type:feature -->
<!-- milestone: M2 · Advanced experience -->
## Goal

Colored syntax highlighting in code blocks, without Rouge (which fails in Ractors) and without runtime dependencies.

## Rules

- **Ruby:** uses `Prism.lex` (ships with Ruby and works inside Ractors). Each token type maps to a category (`keyword`, `string`, `comment`, `constant`, `number`, `ivar`…).
- **Other languages:** `Zat::Highlight::Lexer`, a generic table-driven lexer. Each language is a frozen `Data` with:
  - keywords;
  - string delimiters;
  - line and block comments;
  - a number pattern.
- **v1 languages:** ruby, shell, json, yaml, javascript, python, rust, c, diff and markdown.
- Unknown language, or a block without an info string: plain text, no guessing.
- **Panel:**
  - a `│` gutter and the language name on the first line;
  - long lines truncated with `…` (`--wrap-code` wraps them instead);
  - tabs become 4 spaces.
- Highlighting is a separate phase in the harness (#23).

## Acceptance criteria

- [ ] Fixtures per language, at `:truecolor`, `:ansi256`, `:ansi16` and `:none`
- [ ] Ruby with heredocs, interpolation and `%w[]` highlighted correctly through Prism
- [ ] A 5,000-line block renders in linear time
- [ ] Works inside a Ractor
