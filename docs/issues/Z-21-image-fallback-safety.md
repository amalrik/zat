<!-- title: Images: fallback and safety -->
<!-- labels: milestone:protocols, area:images, type:feature -->
<!-- milestone: M3 · Modern protocols -->
## Goal

Make sure images never break the output, never touch the network, and never read unexpected files.

## Rules

- Relative paths resolve from the `.md` file's directory; for stdin, from the current directory.
- `http(s)://` URLs are never downloaded and go straight to the fallback.
- Default size limit of 10 MB, adjustable with `--max-image-size`.
- Fallback: a styled `🖼 alt (path)`, or `[image: alt]` without color.
- With `--local`, only files inside the document's directory are accepted. Symlinks escaping that directory are refused.

## Acceptance criteria

- [ ] Tests for missing, too large, remote, outside the directory with `--local`, and wrong format
- [ ] No image error interrupts the rest of the document
- [ ] Behavior documented in the README
