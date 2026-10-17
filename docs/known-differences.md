# Known differences

Where Zat's Markdown parser deliberately differs from the [CommonMark spec 0.31.2](https://spec.commonmark.org/0.31.2/) and the [GFM spec 0.29-gfm](https://github.github.com/gfm/). The conformance tests (#5) tag the affected spec examples `:known_difference` or `:out_of_scope` and link back here.

See [ADR 0001](adr/0001-own-parser.md) for why Zat has its own parser.

## Not supported yet

| Feature | Spec sections | Behavior today | Plan |
|---|---|---|---|
| Reference links and link reference definitions | CommonMark 4.7, 6.3 | Definitions are paragraphs; `[text][ref]` is literal text | v1.1 candidate |
| Footnotes | Not in the specs (GFM extension) | Literal text | Not planned |

## Different by design

| Feature | Spec sections | Zat | Why |
|---|---|---|---|
| HTML blocks and inline HTML | CommonMark 4.6, 6.6 | Parsed (`:html_block`, `:html_inline`) but rendered as dimmed text, never interpreted | A terminal can't render HTML |

*Divergences found by the conformance and differential tests (#5) are added here as they're triaged.*
