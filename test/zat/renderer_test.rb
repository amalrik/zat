# frozen_string_literal: true

require "test_helper"
require "zat"
require_relative "../support/golden"
require_relative "../markdown/support/spec_suite"

# Elements the parser can't produce yet are built by hand; the rest live in golden fixtures.
class RendererTest < Minitest::Test
  Node = Zat::Markdown::Node

  def test_nested_inline_styles_reopen_the_outer_one
    strong = node(:strong, text("b"), node(:emph, text("bi")), text("b"))

    assert_equal '\e[1mb\e[3mbi\e[0m\e[1mb\e[0m', render(paragraph(strong))
  end

  def test_styles_are_written_only_with_text
    assert_equal '\e[3m\e[1mb\e[0m', render(paragraph(node(:emph, node(:strong, text("b")), node(:strong))))
  end

  def test_code_span_strikethrough_and_html_inline
    para = paragraph(node(:code, value: "x"), node(:strikethrough, text("s")), node(:html_inline, value: "<b>"))

    assert_equal '\e[37mx\e[0m\e[9ms\e[0m\e[2m<b>\e[0m', render(para)
  end

  def test_styles_close_at_line_ends_and_reopen_on_the_next_line
    assert_equal '\e[1ma\e[0m' + "\n" + '\e[1mb\e[0m', render(paragraph(node(:strong, text("a"), node(:linebreak), text("b"))))
  end

  def test_block_quotes_nest_and_keep_their_bar_on_blank_lines
    quote = node(:block_quote, paragraph(text("a")), node(:block_quote, paragraph(text("b"))))

    assert_equal "│ a\n│\n│ │ b\n", render(quote, depth: :none)
  end

  def test_rules_fit_inside_block_quotes
    assert_equal "│ ────────\n", render(node(:block_quote, node(:thematic_break, line: 1)), depth: :none, columns: 10)
  end

  def test_html_blocks_are_dimmed
    assert_equal '\e[2m<div>\e[0m' + "\n" + '\e[2m</div>\e[0m', render(node(:html_block, value: "<div>\n</div>\n", line: 1))
  end

  def test_control_characters_never_reach_the_terminal
    out = render(paragraph(text("a\e]0;pwned\ab\u009b")), depth: :none)

    assert_equal "a�]0;pwned�b�\n", out
  end

  def test_output_is_utf8_even_when_all_ascii
    assert_equal Encoding::UTF_8, Zat.render("a\n", terminal: Golden.terminal(80)).encoding
  end

  def test_unsupported_nodes_fail_loudly
    assert_raises(ArgumentError) { render(node(:list, line: 1)) }
  end

  def test_no_escapes_without_color
    terminal = Zat::Terminal::Capabilities.new(tty: false, columns: 80, color_depth: :none)

    Golden.names.each do |name|
      refute_includes Zat.render(File.read("#{Golden::DIR}/#{name}.md"), terminal:), "\e", name
    end
  end

  def test_every_spec_example_renders
    terminal = Golden.terminal(80)

    SpecSuite::EXAMPLES.each { Zat.render(it.markdown, terminal:) }
  end

  def test_renders_inside_a_ractor
    terminal = Golden.terminal(80)
    out = Ractor.new(terminal) { Zat.render("# a\n\nb\n", terminal: it) }.value

    assert_equal Zat.render("# a\n\nb\n", terminal:), out
  end

  private

  def render(*children, depth: :ansi16, columns: 20)
    terminal = Zat::Terminal::Capabilities.new(tty: true, columns:, color_depth: depth)
    out = Zat::Renderer.new(terminal:).render(node(:document, *children, line: 1))
    out.gsub("\e", '\e').delete_suffix((depth == :none) ? "" : "\n")
  end

  def node(type, *children, value: nil, line: nil) = Node.new(type:, value:, children:, line:)

  def paragraph(*children) = node(:paragraph, *children, line: 1)

  def text(value) = node(:text, value:)
end
