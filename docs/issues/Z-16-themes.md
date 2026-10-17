<!-- title: Light and dark themes -->
<!-- labels: milestone:advanced, area:terminal, type:feature -->
<!-- milestone: M2 · Advanced experience -->
## Goal

Themes that read well on dark and light backgrounds, covering both text and code.

## Rules

- Selected with `--theme dark|light` or `ZAT_THEME`; the default is `dark`. When `COLORFGBG` is present, the theme is detected from it.
- Each `Theme` is a frozen `Data` that defines the text palette and the token categories from #15.
- Themes are data, not subclasses.

## Acceptance criteria

- [ ] A test fails if any theme lacks a key used by the renderer or the highlighter
- [ ] Normal text has contrast ≥ 4.5 against the assumed background
- [ ] Goldens for both themes
