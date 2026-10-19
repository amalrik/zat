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

  def test_emphasis_nests_its_content
    emph, = Zat::Markdown.parse("*a **b** ~~c~~*").children.first.children

    assert_equal :emph, emph.type
    assert_equal [[:text, "a "], [:strong, nil], [:text, " "], [:strikethrough, nil]], emph.children.map { [it.type, it.value] }
  end

  def test_unmatched_delimiters_merge_into_the_text
    assert_equal [[:text, "*a "], [:emph, nil], [:text, " c_d_e ~~~f~~~ **"]], inlines("*a *b* c_d_e ~~~f~~~ **")
  end

  def test_leftover_delimiters_stay_outside
    assert_equal [[:text, "*"], [:strong, nil]], inlines("***a**")
    assert_equal [[:strong, nil], [:text, "*"]], inlines("**a***")
  end

  def test_links_carry_unescaped_destination_and_title
    link, = Zat::Markdown.parse('[a *b*](/u\\(1\\)&amp; "t &quot;q&quot;")').children.first.children

    assert_equal({destination: "/u(1)&", title: 't "q"'}, link.attrs)
    assert_equal [[:text, "a "], [:emph, nil]], link.children.map { [it.type, it.value] }
  end

  def test_a_link_without_title_omits_it
    assert_equal({destination: ""}, Zat::Markdown.parse("[a]()").children.first.children.first.attrs)
  end

  def test_images_keep_their_description_as_children
    image, = Zat::Markdown.parse("![a [b](c)](d.png)").children.first.children

    assert_equal :image, image.type
    assert_equal %i[text link], image.children.map(&:type)
  end

  def test_links_never_nest
    assert_equal [[:text, "[a "], [:link, nil], [:text, "](d)"]], inlines("[a [b](c)](d)")
  end

  private

  def inlines(source) = Zat::Markdown.parse(source).children.first.children.map { [it.type, it.value] }
end
