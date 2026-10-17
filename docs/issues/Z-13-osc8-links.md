<!-- title: OSC 8 hyperlinks with fallback -->
<!-- labels: milestone:mvp, area:renderer, area:terminal, type:feature -->
<!-- milestone: M1 · MVP -->
## Goal

Clickable links on terminals that support OSC 8, readable links everywhere else.

## Rules

- **With OSC 8:** a link is emitted as `\e]8;;URL\e\\text\e]8;;\e\\`, in the `link` style.
- **Without OSC 8:** the text becomes `text[1]`, and a "Links" section at the end of the document lists the URLs.
- Autolinks, and links whose text is the URL itself, get no numbered reference.
- Anchors (`#section`) are shown as text only.
- OSC 8 support is detected from `TERM_PROGRAM` and `TERM`, using a conservative list.

## Acceptance criteria

- [ ] Fixtures with OSC 8 and with the fallback
- [ ] URLs with special characters are emitted correctly
- [ ] Wrapping (#12) never splits an OSC 8 sequence
