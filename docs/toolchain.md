# Toolchain

The Ruby build Zat is developed and measured against. Every version bump produces a new benchmark baseline (#26).

## Current version

| Item | Value |
|---|---|
| Ruby | `ruby 4.1.0preview1 (2026-10-11 master 2d08b5f42f) +PRISM [x86_64-linux]` |
| Commit | `2d08b5f42f` |
| rustc | `1.99.0 (b940084d7 2026-09-28)` (Arch Linux) |
| mise | `2026.10.11` |
| JITs in the build | ZJIT ✅ · YJIT ✅ |
| Installed | 2026-10-17 |

The version is pinned in [`mise.toml`](../mise.toml).

## Installing

By default, mise downloads **prebuilt** Ruby binaries, which ship with YJIT only (`--enable-yjit`). To get ZJIT, build from source with `rustc` on the PATH:

```bash
MISE_RUBY_COMPILE=true mise install ruby@4.1.0-preview1
```

mise did **not** forward `RUBY_CONFIGURE_OPTS="--enable-zjit"`: the build's `configure_args` don't include it. ZJIT got in because `configure` detected `rustc` by itself. Always verify:

```bash
ruby --zjit -e 'p RubyVM::ZJIT.enabled?'   # => true
ruby --yjit -e 'p RubyVM::YJIT.enabled?'   # => true
```

If you see `Ruby was built without ZJIT support`, `rustc` wasn't visible during the build.

> Watch out: if a parent directory has a `mise.toml`, `mise use` writes there instead of in the project. This repository has its own `mise.toml`.

## ZJIT flags (`ruby --help`)

| Flag | Description | Used in Zat |
|---|---|---|
| `--zjit` | Enable ZJIT | `zjit` config |
| `--zjit-call-threshold=num` | Calls before compiling (default: **30**) | `zjit-t1` config with `=1` |
| `--zjit-num-profiles=num` | Profiled calls before compiling (default: 5) | Warm-up experiments |
| `--zjit-mem-size=num` | Max ZJIT memory in MiB (default: 128) | — |
| `--zjit-stats[=file]` | Collect stats; `=x.json` writes JSON | #25 |
| `--zjit-stats-quiet` | Collect stats without printing | #25, read via `RubyVM::ZJIT.stats` |
| `--zjit-disable` | Load disabled; enable with `RubyVM::ZJIT.enable` | Possible selective warm-up |
| `--zjit-perf[=iseq\|hir]` | Symbols for `perf` in `/tmp/perf-{pid}.map` | Profiling |
| `--zjit-log-compiled-iseqs=path` | Log compiled ISEQs | #25 |
| `--zjit-trace-exits[=counter]` | Record side-exit sources | #25 (top side exits → Ruby method) |
| `--zjit-trace-exits-sample-rate=num` | Side-exit sampling rate | — |
| `--zjit-trace-compiles` | Compilation phases as Perfetto trace events | Visualizing warm-up (#23) |
| `--zjit-trace-invalidation` | Invalidations as Perfetto trace events | — |

## `RubyVM::ZJIT` API

```
assert_compiles  enable  enabled?  induce_breakpoint!  induce_compile_failure!
induce_side_exit!  reset_stats!  stats  stats_enabled?  stats_string
trace_exit_locations_enabled?
```

- `RubyVM::ZJIT.stats` returns a `Hash` with **788 keys** in this build. The most relevant for the lab:
  - `compiled_iseq_count`, `failed_iseq_count`;
  - `compile_time_ns`, plus the `compile_hir_*_time_ns` and `compile_lir_time_ns` phases;
  - `side_exit_count`, `compiled_side_exit_count`, `exit_*` (by reason);
  - `send_fallback_*`, `unspecialized_send_*`, `getivar_fallback_*`, `setivar_fallback_*` (where ZJIT didn't specialize);
  - `unhandled_yarv_*` (instructions not yet supported);
  - `code_region_bytes`, `total_mem_bytes`, `zjit_insn_count`.
- `reset_stats!` makes it possible to measure a specific span, e.g. reset after warm-up and measure only the steady state.
- `stats_string` returns the formatted report printed at exit (top non-inlined C methods, optimized sends, etc.).

## Ractors in 4.1

- Instance methods: `<<`, `send`, `value`, `join`, `monitor`, `unmonitor`, `default_port`, `close`, `[]`, `[]=`, `name`.
- Class methods: `new`, `current`, `main`, `main?`, `receive`/`recv`, `select`, `make_shareable`, `shareable?`, `shareable_proc`, `shareable_lambda`, `store_if_absent`, `count`.
- `Ractor::Port` exists. `take` and `yield` are gone.
- **The warning is still emitted:** `warning: Ractor API is experimental and may change in future versions of Ruby.`

## First measurement on 4.1 (preliminary)

Pure-Ruby ANSI string building, 4 tasks, one run each:

```ruby
def work = (b = +""; 300_000.times { |i| s = "item #{i}"; b << "\e[1m" << s << "\e[0m " if s.end_with?("7") || i.even? }; b.bytesize)
# sequential: 4.times { work }
# parallel:   Array.new(4) { Ractor.new { work } }.each(&:value)
```

| Config | Sequential | 4 Ractors | Speedup |
|---|---|---|---|
| interp | 0.82 s | 0.23 s | 3.6x |
| yjit | 0.69 s | 0.17 s | 4.0x |
| zjit | 0.61 s | 0.16 s | 3.9x |

The same test gave **~1.9x** on 4.0.7. The allocation-contention hypothesis (#32) **does not hold on 4.1** for this workload. ZJIT is also already ahead of YJIT on this microbenchmark. These are single runs; the lab will confirm them.
