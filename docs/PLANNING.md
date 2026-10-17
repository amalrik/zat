# Zat — Engineering Plan

> A pure-Ruby clone of `mdcat`, with its own Markdown parser, and a measurement lab for **ZJIT** and **Ractors** on Ruby 4.1.
> Revised 2026-10-17. Issues: [#1–#32](https://github.com/amalrik/zat/issues) (sources in [`docs/issues/`](issues/); `Z-NN` = issue `#NN`).
> Project board: <https://github.com/users/amalrik/projects/2>

---

## 0. Decisions and evidence

### 0.1 Decisions

| Decision | Why |
|---|---|
| **ZJIT is the target; YJIT is a reference column only** | ZJIT is YJIT's successor and where feedback matters. YJIT only answers "has ZJIT caught up on this code?" |
| **Ruby 4.1** (`4.1.0-preview1` today; RC when released, usually December) | ZJIT's target release. Every result records the exact Ruby commit — see [`toolchain.md`](toolchain.md) |
| **Own Markdown parser** (`Zat::Markdown`), designed to be extracted as a standalone gem | No pure-Ruby Markdown gem runs inside a Ractor (see 0.2), and an own parser turns parsing into Ruby code ZJIT can actually optimize |
| **kramdown is dev-only**: oracle for differential tests and a benchmark comparison point | Correctness reference without a runtime dependency |
| **Zero runtime dependencies** | Rouge and `unicode-display_width` also break in Ractors. Highlighting uses Prism for Ruby (ships with Ruby, Ractor-safe) plus an own table-driven highlighter; display width uses an own table |
| **Ractors are part of the product** (batch mode, `--jobs N`) | Gives both JIT warm-up and parallelism a real use case |

### 0.2 Measurements behind these decisions

Ruby 4.0.7 (YJIT as a stand-in for ZJIT), ~9,800-line document:

| Phase | Interpreter | YJIT | Speedup |
|---|---|---|---|
| kramdown parse (GFM) | 0.86–0.95 s | 0.68–0.72 s | ~1.25x (time is in regex/C) |
| Rouge lexing | 1.12 s | 0.60 s | ~1.9x |
| AST walk (simulated render) | 0.43 s | 0.27 s | ~1.55x |

| Run inside a non-main Ractor | Result |
|---|---|
| `Kramdown::Document.new` | ❌ `Ractor::IsolationError` (`@options` on `Kramdown::Options`) |
| `Rouge::Lexers::Ruby.new`, `Rouge::Lexer.find` | ❌ `Ractor::IsolationError` (`@registry`, `eager_load!`) |
| `Unicode::DisplayWidth.of` | ❌ `Ractor::IsolationError` (`EmojiSupport.recommended`) |
| `Prism.lex` | ✅ |
| `Array#pack("m0")` (base64) | ✅ |

Ractor scaling of pure-Ruby ANSI string building, with 4 Ractors:

| Ruby | Speedup over sequential |
|---|---|
| 4.0.7 | ~1.9x on a 16-core machine |
| 4.1.0-preview1 | **3.6–4.0x** (see [`toolchain.md`](toolchain.md)) |

Caveats: YJIT is not ZJIT, and these were few runs. The numbers show direction, not results; the lab exists to redo them properly.

---

## 1. Scope: mdcat vs Zat

| mdcat feature | Zat | Milestone |
|---|---|---|
| CommonMark + GFM | **Documented subset** (see 1.2), tested against the spec and kramdown | M1 / M2 |
| Headings, emphasis, lists, quotes, rules, inline code | Yes | M1 |
| File(s) and stdin | Yes | M1 |
| OSC 8 hyperlinks | Yes, with numbered fallback | M1 |
| TTY detection / no color | Yes, including `NO_COLOR` | M1 |
| Syntax highlighting | Ruby via Prism; other languages via own highlighter | M2 |
| GFM tables | Yes, Unicode borders and alignment | M2 |
| Paging | Yes, via `$PAGER` | M2 |
| Inline images (Kitty, iTerm2) | Kitty (PNG), iTerm2 (any format) | M3 |
| Remote images | Out of scope | — |
| **Batch mode with Ractors** (`zat docs/**/*.md --jobs N`) | New, not in mdcat | Lab · Ractors |

### 1.1 Milestones

- **M0 · Foundation**: Ruby 4.1 toolchain with ZJIT, skeleton, parser ADR, golden tests, conformance and differential tests.
- **M1 · MVP**: block and inline parsers, terminal, renderer, lists, wrapping, links.
- **M2 · Advanced experience**: tables, syntax highlighting, themes, paging.
- **M3 · Modern protocols**: Kitty and iTerm2 images, fallback and safety rules.
- **Lab · ZJIT**: starts once the parser and basic renderer exist (#7, #8, #10).
- **Lab · Ractors**: starts alongside Lab · ZJIT. The Ractor-safety guard (#31) is in CI **from M1 on**, so nothing silently grabs global state.

### 1.2 Supported Markdown subset

**In v1:**

- Blocks: ATX and setext headings, paragraphs, hard breaks (two spaces and `\`), thematic breaks, block quotes (nested), ordered and bullet lists (tight/loose, nested), fenced code (` ``` ` and `~~~`, info string), indented code.
- Inline: backslash escapes, HTML entities, code spans, emphasis and strong (spec delimiter-run algorithm), inline links and images, autolinks.
- GFM: tables, strikethrough, task lists, extended autolinks (`www.`, `https://`).

**Out of scope or deferred** (tracked in `docs/known-differences.md`):

- reference links and link definitions (v1.1 candidate);
- HTML blocks (rendered as dimmed text, never interpreted);
- footnotes and rare lazy-continuation cases.

### 1.3 Architecture

```
exe/zat                          Zat::CLI.start(ARGV)
lib/zat.rb
lib/zat/markdown.rb              ┐ Zat::Markdown — the future gem.
lib/zat/markdown/node.rb         │  Depends on NOTHING in Zat::*.
lib/zat/markdown/block_parser.rb │  Data.define nodes, frozen
lib/zat/markdown/inline_parser.rb│  constants, no class-level state.
lib/zat/markdown/entities.rb     ┘  API: Zat::Markdown.parse(str) → Node
lib/zat/cli.rb                   Zat::CLI        options, inputs, pager, --jobs
lib/zat/batch.rb                 Zat::Batch      distributes files to Ractors
lib/zat/terminal.rb              Zat::Terminal   tty, columns, color, images
lib/zat/style.rb / theme.rb      Zat::Style / Zat::Theme (Data, shareable)
lib/zat/width.rb                 Zat::Width      own display-width table
lib/zat/text.rb                  Zat::Text       ANSI-aware wrapping
lib/zat/renderer.rb              Zat::Renderer   AST → buffer
lib/zat/table.rb                 Zat::Table      table layout
lib/zat/highlight.rb             Zat::Highlight  Prism (Ruby) + own highlighter
lib/zat/image.rb                 Zat::Image      Kitty / iTerm2
```

**Ractor-safety rules** (enforced by #31):

- every constant is `Ractor.make_shareable` or a frozen literal;
- no class/module instance variable is written after boot;
- no global lazy caches; caches live on instances only;
- `Terminal` and `Theme` are resolved in the main Ractor and passed to workers already shareable.

**JIT-aware style, without distorting the code:**

- **idiomatic code first**; "JIT-friendly" variants live only in microbenchmarks (#27);
- one output buffer per document (`String.new(capacity:)` with `<<`);
- dispatch with `case node.type`;
- the parser deliberately chooses where to use `StringScanner`/regex and where to scan bytes, and both styles are benchmarked (#27).

**Future gem extraction:** `Zat::Markdown` has its own tests in `test/markdown/` and knows nothing about terminals. Extracting it means moving `lib/zat/markdown*` and `test/markdown/` and renaming the namespace.

---

## 2. ZJIT lab

### 2.1 Run matrix

| ID | Command | Role |
|---|---|---|
| `interp` | `ruby exe/zat` | Baseline |
| `zjit` | `ruby --zjit exe/zat` | **Target** |
| `zjit-t1` | `ruby --zjit --zjit-call-threshold=1` | Isolates compilation cost (default threshold: 30) |
| `zjit-stats` | `ruby --zjit --zjit-stats=out.json` | Stats only, never timed |
| `yjit` | `ruby --yjit exe/zat` | Reference ("has ZJIT caught up?") |

All JIT flags live in `bench/config.rb` only. The full flag list is in [`toolchain.md`](toolchain.md).

### 2.2 Scenarios

**A · Warm-up and compilation overhead**

- *Cold:* a new process per run, N=30, per file and size. This is real CLI usage.
- *Warm:* the same document rendered K=200 times in-process, with each iteration timed.
- *Batch:* `zat corpus/*.md`, the real use case that justifies the warm mode.
- Metrics:
  - stabilization iteration (CV < 3% over a window of 10);
  - time to stabilize;
  - warm-up cost;
  - **break-even** against `interp` (in iterations, and in number of files for batch mode).
- `--zjit-stats` is cross-referenced with the curve: compile time, compiled ISEQs, side exits. `--zjit-trace-compiles` provides a Perfetto view of the warm-up.

**B · String and AST traversal stress**

- Deterministic synthetic corpus: four profiles (`prose`, `code-heavy`, `table-heavy`, `mixed`) × three sizes (1k, 10k, 100k lines), plus a real-world corpus pinned by hash.
- Phases, each measured separately: **block parse**, **inline parse**, **highlight**, **render**, **write**.
- Per phase:
  - time;
  - allocated objects;
  - `malloc_increase_bytes`;
  - minor and major GC count;
  - `GC.stat(:time)`;
  - peak RSS.
- Normalized: objects per input line; output bytes per millisecond.

**C · Automated comparisons**

- `rake bench` runs matrix × corpus × mode and writes `bench/results/<date>-<ruby-commit>/`: `raw.jsonl`, `summary.csv`, `REPORT.md`, `env.json`.
- Every cell reports median, p95, stddev and speedup over `interp` with a bootstrap 95% CI.
- **Own parser vs kramdown** on the same corpus and matrix: "idiomatic parser written for 4.1" vs "popular gem's parser".

**D · ZJIT correctness** (cheap, and the most valuable feedback)

- Zat's own suite runs in CI with `--zjit` and `--zjit-call-threshold=1`.
- The kramdown and Rouge test suites run under `--zjit`. A failure that doesn't happen in the interpreter is a miscompilation candidate.

### 2.3 Microbenchmarks (#27)

| Name | Question |
|---|---|
| `scan_style` | Block parser with `StringScanner`+regex vs `getbyte`/`byteindex` scanning |
| `delimiters` | Emphasis delimiter stack: struct arrays vs `Data` vs hashes |
| `width` | Own table with `bsearch` vs `case` with ranges |
| `wrap` | `each_char` vs index + `getbyte` |
| `buffer` | `<<` vs interpolation vs `Array#join` vs `StringIO` |
| `dispatch` | `case/when` vs `send` vs hash of lambdas vs one class per node |
| `sgr` | Build on the fly vs frozen cache |
| `kramdown_parse` | Negative control: low speedup expected (regex-bound) |

---

## 3. Ractor lab

| Scenario | Measured |
|---|---|
| **Scaling** | `zat --jobs N`, N ∈ {1, 2, 4, 8, 16}, over 64 `mixed-1k` files, under `interp` and `zjit`: total time, speedup, efficiency (speedup/N) |
| **Contention** | Same runs with per-Ractor and global `GC.stat`; allocation-heavy vs allocation-light profiles to separate CPU from allocation |
| **ZJIT × Ractors** | Does the ZJIT speedup hold with N Ractors? Is compiled code shared, or is warm-up repeated per Ractor? |
| **Communication cost** | Send the path and read in the worker vs send the content; return output by copy vs `move: true` |

The 4.0.7 hypothesis (string allocation doesn't scale across Ractors) **did not reproduce on 4.1.0-preview1** in a first quick run. The lab measures it properly on the real workload. Any finding is reported with a minimal reproduction outside Zat.

---

## 4. GitHub: labels, milestones, Project

### 4.1 Milestones

| Milestone | Issues |
|---|---|
| `M0 · Foundation` | #1 – #5 |
| `M1 · MVP` | #6 – #13 |
| `M2 · Advanced experience` | #14 – #17 |
| `M3 · Modern protocols` | #18 – #21 |
| `Lab · ZJIT` | #22 – #29 |
| `Lab · Ractors` | #30 – #32 |

### 4.2 Labels

| Label | Color | Use |
|---|---|---|
| `milestone:setup` `milestone:mvp` `milestone:advanced` `milestone:protocols` | `#0E8A16` | Mirror the milestones |
| `area:cli` `area:parser` `area:renderer` `area:terminal` `area:text` `area:tables` `area:syntax` `area:images` | `#1D76DB` | Component |
| `area:infra` `area:tests` `area:performance` | `#5319E7` | Cross-cutting |
| `experiment:zjit` | `#D93F0B` | Produces or consumes ZJIT data |
| `experiment:ractor` | `#E99695` | Produces or consumes Ractor data |
| `zjit:hot-path` | `#FBCA04` | Shows up in profiles; changes need `rake bench:quick` |
| `ractor-safety` | `#F9D0C4` | Touches constants or shared state |
| `gem:markdown` | `#BFDADC` | Code of the future `Zat::Markdown` gem |
| `type:feature` `type:chore` `type:research` | `#C5DEF5` | Kind of work |
| `blocked` | `#B60205` | External dependency |

### 4.3 GitHub Project

Project **"Zat"** fields:

| Field | Type | Values |
|---|---|---|
| Status | Single select | `Backlog` · `Ready` · `In progress` · `In review` · `Done` |
| Track | Single select | `Product` · `Parser` · `Lab ZJIT` · `Lab Ractors` |
| Size | Single select | `S` (≤½ day) · `M` (1–2 days) · `L` (3+ days) |
| JIT impact | Single select | `Hot path` · `Neutral` · `N/A` |
| Iteration | Iteration | 2 weeks |
| Depends on | Text | `#N` |

Views:

1. **Kanban:** board by `Status`, swimlanes by `Track`.
2. **By milestone:** table grouped by milestone, sorted by number.
3. **Timeline:** roadmap by `Iteration`. Labs run in parallel from the end of M1.
4. **Findings:** table filtered by `experiment:zjit` or `experiment:ractor`.

Workflows: item added → `Backlog`; PR linked → `In review`; issue closed → `Done`.

### 4.4 Critical path

```
#1 ─┬─ #2 ─┬─ #3 ─ #7 ─ #8 ─┬─ #10 ─┬─ #11 ─ … M1
    │      ├─ #4 ───────────┤       └─ #12 ─ #14 (tables)
    │      ├─ #5 (diff) ────┘
    │      └─ #6, #9
    │                  #31 (Ractor-safety in CI from M1)
    ├─ #28 (gem suites under --zjit: can start now)
    └──────────── #22 ─ #23 ─┬─ #24, #25 ─ #26 ─ #29
                             └─ #30 ─ #32
```

#28 depends only on the toolchain. It can produce the first ZJIT feedback before a single line of the parser exists.

---

## 5. Issue index

| # | Title | Milestone |
|---|---|---|
| 1 | Toolchain: Ruby 4.1 with ZJIT | M0 |
| 2 | Project skeleton, Gemfile and CI | M0 |
| 3 | ADR: own parser and Ractor-safety rules | M0 |
| 4 | Golden tests for ANSI output | M0 |
| 5 | Parser conformance and differential tests | M0 |
| 6 | CLI: file and stdin input | M1 |
| 7 | Block parser | M1 |
| 8 | Inline parser | M1 |
| 9 | Terminal, Style and Theme | M1 |
| 10 | Renderer: basic blocks and inlines | M1 |
| 11 | Lists and task lists | M1 |
| 12 | Display width and line wrapping | M1 |
| 13 | OSC 8 hyperlinks with fallback | M1 |
| 14 | GFM tables with Unicode borders | M2 |
| 15 | Syntax highlighting: Prism + own highlighter | M2 |
| 16 | Light and dark themes | M2 |
| 17 | Paging via $PAGER | M2 |
| 18 | Image protocol detection | M3 |
| 19 | Images via the Kitty graphics protocol | M3 |
| 20 | Images via iTerm2 inline images | M3 |
| 21 | Images: fallback and safety | M3 |
| 22 | Benchmark corpus generator | Lab ZJIT |
| 23 | In-process warm-up harness | Lab ZJIT |
| 24 | Per-phase memory and allocation metrics | Lab ZJIT |
| 25 | ZJIT stats collection | Lab ZJIT |
| 26 | Comparative runner | Lab ZJIT |
| 27 | Hot-path microbenchmarks | Lab ZJIT |
| 28 | Third-party test suites under --zjit | Lab ZJIT |
| 29 | Findings report and upstream feedback template | Lab ZJIT |
| 30 | Batch mode with Ractors (--jobs) | Lab Ractors |
| 31 | Ractor-safety enforced in CI | Lab Ractors |
| 32 | Ractor scaling and contention benchmark | Lab Ractors |
