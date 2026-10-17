<!-- title: Images via the Kitty graphics protocol -->
<!-- labels: milestone:protocols, area:images, type:feature -->
<!-- milestone: M3 · Modern protocols -->
## Goal

Show local PNG images inline on terminals that support the Kitty graphics protocol.

## Rules

- PNG only, recognized by the `\x89PNG\r\n\x1a\n` signature and sent with `f=100`. The terminal does the decoding.
- The content is base64-encoded with `[bytes].pack("m0")` (Ractor-safe) and split into 4096-byte chunks:
  - `\e_Ga=T,f=100,q=2,c=<cols>,m=1;<chunk>\e\\` for every chunk except the last;
  - `\e_Gm=0;<chunk>\e\\` for the last one.
- Width and height come from IHDR (bytes 16–23). `c=` caps the image at `columns`, preserving the aspect ratio.
- A newline after the image.

## Acceptance criteria

- [ ] Golden test with a small PNG in `test/fixtures/img/`
- [ ] A 2 MB PNG produces the right number of chunks
- [ ] Non-PNG images go to the fallback (#21)
- [ ] Manual test in Kitty and Ghostty, with a screenshot in the PR
