# Zat

Render Markdown in the terminal, in pure Ruby: colors, tables, syntax highlighting and inline images, in the spirit of [mdcat](https://github.com/swsnr/mdcat).

Zat is also a lab. It is written to produce empirical feedback on **ZJIT** and **Ractors** for Ruby 4.1, which is why it has its own Markdown parser and zero runtime dependencies (see [decisions](docs/decisions.md)).

> **Status:** early development. Nothing renders yet — see the [roadmap](docs/ROADMAP.md) and the [project board](https://github.com/users/amalrik/projects/2).

## Requirements

Ruby 4.1 built with ZJIT. See [docs/toolchain.md](docs/toolchain.md) for how to build it with mise.

## Development

```bash
bundle install
bundle exec rake                  # lint (Standard) + whole suite
bundle exec rake test             # whole suite
bundle exec rake test:markdown    # the Markdown parser alone
RUBYOPT=--zjit bundle exec rake test
bundle exec rake standard:fix     # autofix style
bundle exec exe/zat --version
```

## License

[MIT](LICENSE)
