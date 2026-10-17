# frozen_string_literal: true

require "json"
require "net/http"

COMMONMARK = "https://spec.commonmark.org/0.31.2/spec.json"
GFM = "https://raw.githubusercontent.com/github/cmark-gfm/0.29.0.gfm.13/test/spec.txt"
# Task-list examples are "disabled" upstream only because cmark-gfm's own
# test runner can't check them; their expected HTML is fine.
GFM_EXTENSIONS = %w[table strikethrough autolink disabled].freeze
OUT = File.expand_path("../test/markdown/spec", __dir__)

def fetch(url) = Net::HTTP.get_response(URI(url)).tap(&:value).body.force_encoding("UTF-8")

def gfm_extension_examples(text)
  fence = "`" * 32
  section = nil
  number = 0
  examples = []
  lines = text.lines
  until lines.empty?
    line = lines.shift
    section = line[/\A#+ (.+)/, 1].strip if line.start_with?("#")
    next unless line.start_with?("#{fence} example")

    number += 1
    extension = line.split[2]
    body = lines.take_while { !it.start_with?(fence) }
    lines.shift(body.size + 1)
    markdown, html = body.join.split(/^\.\n/, 2).map { it.tr("→", "\t") }
    next unless GFM_EXTENSIONS.include?(extension)

    examples << {"example" => number, "section" => section, "markdown" => markdown, "html" => html}
  end
  examples
end

File.write(File.join(OUT, "commonmark-0.31.2.json"), JSON.pretty_generate(JSON.parse(fetch(COMMONMARK))) + "\n")
File.write(File.join(OUT, "gfm-0.29-extensions.json"), JSON.pretty_generate(gfm_extension_examples(fetch(GFM))) + "\n")
