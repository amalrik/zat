# Spec examples

- `commonmark-0.31.2.json`: the examples of the [CommonMark Spec 0.31.2](https://spec.commonmark.org/0.31.2/) by John MacFarlane.
- `gfm-0.29-extensions.json`: the extension examples (tables, task lists, strikethrough, autolinks) of the [GitHub Flavored Markdown Spec 0.29-gfm](https://github.github.com/gfm/).

Both specs are licensed under [CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/); these files are unmodified extracts, regenerated with `ruby script/fetch_spec_examples.rb`.

`passing.txt` lists the examples Zat passes. `rake spec:update` rewrites it; `rake spec:report` shows progress per section.
