# frozen_string_literal: true

require "test_helper"
require "zat/markdown"

# What the spec's HTML can't show: node shapes. Conformance is in spec_test.rb.
class InlineTest < Minitest::Test
  def test_adjacent_text_is_merged
    assert_equal [[:text, "a&b*c<d"]], inlines("a&amp;b\\*c<d")
  end

  def test_line_breaks
    assert_equal [[:text, "a"], [:linebreak, nil], [:text, "b"], [:softbreak, nil], [:text, "c"]], inlines("a  \nb\nc")
  end

  def test_code_spans_autolinks_and_html_are_leaves
    code, _, link, _, html = Zat::Markdown.parse("`x` <https://a.b> <b>").children.first.children

    assert_equal "x", code.value
    assert_equal({destination: "https://a.b", autolink: true}, link.attrs)
    assert_equal "<b>", html.value
  end

  def test_unescape_handles_escapes_and_entities_only
    assert_equal "a*b&ö&nope;*", Zat::Markdown::InlineParser.unescape("a\\*b&amp;&ouml;&nope;*")
  end

  def test_invalid_numeric_references_become_the_replacement_character
    assert_equal [[:text, "\uFFFD\uFFFD\uFFFD"]], inlines("&#0;&#xD800;&#x110000;")
  end

  private

  def inlines(source) = Zat::Markdown.parse(source).children.first.children.map { [it.type, it.value] }
end
