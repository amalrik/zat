<!-- title: Hot-path microbenchmarks -->
<!-- labels: area:performance, experiment:zjit, zjit:hot-path, type:research -->
<!-- milestone: Lab · ZJIT -->
## Goal

Isolate idiomatic Ruby patterns and find out where ZJIT helps, where it's neutral, and where it hurts.

## Microbenchmarks

| Name | Variants |
|---|---|
| `scan_style` | Block parser with `StringScanner` + regex vs `getbyte`/`byteindex` scanning |
| `delimiters` | Delimiter stack with `Struct` vs `Data` vs `Hash` vs parallel arrays |
| `width` | `bsearch` over ranges vs `case` with literal ranges |
| `wrap` | `each_char` vs index + `getbyte` |
| `buffer` | `<<` vs interpolation vs `Array#join` vs `StringIO` |
| `dispatch` | `case/when` vs `send(:"render_#{t}")` vs hash of lambdas vs one class per node type |
| `sgr` | Build on the fly vs frozen cache |
| `kramdown_parse` | Negative control: low speedup expected, since time is in regex |

## Rules

- Same harness as #23 (it measures the curve, not just the mean). `kramdown_parse` runs with `bench/Gemfile`.
- All variants of a microbenchmark must produce the same result, and this is checked.
- For each microbenchmark, the report records the verdict (helps, neutral or hurts) and why, with stats from #25.
- A variant only goes into product code if it's better under ZJIT **and** just as readable as the current one.

## Acceptance criteria

- [ ] All 8 microbenchmarks implemented, with result verification
- [ ] The negative control shows a low speedup; if not, the measurement method is investigated
- [ ] Verdicts recorded in `docs/zjit-findings.md`
