# frozen_string_literal: true

require "json"
require_relative "spec_html"

module SpecSuite
  DIR = File.expand_path("../spec", __dir__)
  PASSING = File.join(DIR, "passing.txt")
  SOURCES = {"commonmark" => "commonmark-0.31.2.json", "gfm" => "gfm-0.29-extensions.json"}.freeze

  Row = Data.define(:spec, :section, :passed, :total)

  Example = Data.define(:spec, :number, :section, :markdown, :html) do
    def id = "#{spec} #{number}"
    def to_s = "#{id}  #{section}"
  end

  EXAMPLES = SOURCES.flat_map { |spec, file|
    JSON.parse(File.read(File.join(DIR, file))).map do |e|
      Example.new(spec:, number: e["example"], section: e["section"], markdown: e["markdown"], html: e["html"])
    end
  }.freeze

  module_function

  def examples = EXAMPLES

  def render(example) = SpecHTML.render(Zat::Markdown.parse(example.markdown))

  def passes?(example) = render(example) == example.html

  def passing_ids
    File.exist?(PASSING) ? File.readlines(PASSING).map { it[/\A\w+ \d+/] } : []
  end

  def update!
    passing = examples.select { passes?(it) }
    File.write(PASSING, passing.map { "#{it}\n" }.join)
    passing.size
  end

  def report
    examples.group_by { [it.spec, it.section] }.map do |(spec, section), group|
      Row.new(spec:, section:, passed: group.count { passes?(it) }, total: group.size)
    end
  end
end
