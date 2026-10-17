# frozen_string_literal: true

# Prints the AST of a Markdown file as an indented tree.
#
#   bundle exec ruby script/dump_ast.rb FILE              # Zat::Markdown
#   bundle exec ruby script/dump_ast.rb --kramdown FILE   # kramdown (GFM)

require "optparse"

parser = :zat
OptionParser.new do |opts|
  opts.banner = "Usage: script/dump_ast.rb [--kramdown] FILE"
  opts.on("--kramdown", "Show kramdown's AST instead of Zat's") { parser = :kramdown }
end.parse!

abort "Usage: script/dump_ast.rb [--kramdown] FILE" unless ARGV.size == 1
source = File.read(ARGV.first)

def show(type, value, attrs, depth)
  line = "#{"  " * depth}#{type}"
  line << " #{value.inspect}" if value
  line << " #{attrs.inspect}" unless attrs.empty?
  puts line
end

def dump_zat(node, depth = 0)
  show(node.type, node.value, node.line ? node.attrs.merge(line: node.line) : node.attrs, depth)
  node.children.each { dump_zat(it, depth + 1) }
end

# kramdown's options carry bookkeeping (source location, encoding, ...)
# that only adds noise here.
KRAMDOWN_NOISE = %i[location encoding options abbrev_defs abbrev_attr footnote_count].freeze

def dump_kramdown(element, depth = 0)
  return if element.type == :blank

  show(element.type, element.value, element.attr.merge(element.options.except(*KRAMDOWN_NOISE)), depth)
  element.children.each { dump_kramdown(it, depth + 1) }
end

case parser
when :kramdown
  require "kramdown"
  require "kramdown-parser-gfm"
  dump_kramdown(Kramdown::Document.new(source, input: "GFM").root)
when :zat
  require_relative "../lib/zat/markdown"
  abort "Zat::Markdown.parse doesn't exist yet (it arrives with #7). Use --kramdown." unless Zat::Markdown.respond_to?(:parse)
  dump_zat(Zat::Markdown.parse(source))
end
