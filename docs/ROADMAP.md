# Roadmap

What Zat will do, compared with mdcat, and in what order. Work items: [issues](https://github.com/amalrik/zat/issues) and the [project board](https://github.com/users/amalrik/projects/2).

## Scope

| mdcat feature | Zat | Milestone |
|---|---|---|
| CommonMark + GFM | The subset below, checked against the spec examples | M1 / M2 |
| Headings, emphasis, lists, quotes, rules, inline code | Yes | M1 |
| File(s) and stdin | Yes | M1 |
| OSC 8 hyperlinks | Yes, with numbered fallback | M1 |
| TTY detection / no color | Yes, including `NO_COLOR` | M1 |
| Syntax highlighting | Ruby via Prism; other languages via own highlighter | M2 |
| GFM tables | Yes, Unicode borders and alignment | M2 |
| Paging | Yes, via `$PAGER` | M2 |
| Inline images (Kitty, iTerm2) | Kitty (PNG), iTerm2 (any format) | M3 |
| Remote images | Out of scope | — |
| Batch mode (`zat docs/**/*.md --jobs N`) | New, with a Ractor worker pool | Lab · Ractors |

## Markdown in v1

- **Blocks:** ATX and setext headings, paragraphs, hard breaks, thematic breaks, nested block quotes, ordered and bullet lists (tight/loose, nested), fenced and indented code.
- **Inlines:** backslash escapes, entities, code spans, emphasis and strong, inline links and images, autolinks.
- **GFM:** tables, strikethrough, task lists, extended autolinks.

Everything else, and every deliberate deviation from the specs, is in [known-differences.md](known-differences.md).

## Critical path

```
#1 ─┬─ #2 ─┬─ #3 ─ #7 ─ #8 ─┬─ #10 ─┬─ #11 ─ … M1
    │      ├─ #4 ───────────┤       └─ #12 ─ #14 (tables)
    │      ├─ #5 (spec) ────┘
    │      └─ #6, #9
    │                  #31 (Ractor-safety in CI from M1)
    ├─ #28 (gem suites under --zjit: can start now)
    └──────────── #22 ─ #23 ─┬─ #24, #25 ─ #26 ─ #29
                             └─ #30 ─ #32
```

- The labs start once the parser and basic renderer exist (#7, #8, #10).
- #28 needs only the toolchain, so it can produce ZJIT feedback before the parser does.
