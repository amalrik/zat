<!-- title: Images via iTerm2 inline images -->
<!-- labels: milestone:protocols, area:images, type:feature -->
<!-- milestone: M3 · Modern protocols -->
## Goal

Show local images inline in iTerm2 and WezTerm via OSC 1337.

## Rules

- Sequence: `\e]1337;File=name=<b64 name>;size=<bytes>;inline=1;width=<N>;preserveAspectRatio=1:<b64 file>\a`.
- Accepted formats: PNG, JPEG and GIF, identified by magic bytes. Zat never decodes images.
- `width` is capped at `columns`.

## Acceptance criteria

- [ ] Golden tests with PNG and JPEG
- [ ] File names with non-ASCII characters work
- [ ] Manual test documented in the PR
