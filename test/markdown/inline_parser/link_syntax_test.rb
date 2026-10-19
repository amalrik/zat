# frozen_string_literal: true

require "test_helper"
require "zat/markdown"
require_relative "../support/scanning"

class LinkSyntaxTest < Minitest::Test
  include Scanning

  MAX_PAREN_DEPTH = Zat::Markdown::InlineParser::LinkSyntax::MAX_PAREN_DEPTH

  def test_destination_and_title_are_unescaped
    assert_equal [{destination: "/a(b)", title: 't "q"'}, " x"], link('(/a\(b\) "t &quot;q&quot;") x')
  end

  def test_every_title_delimiter
    ['"t"', "'t'", "(t)"].each { assert_equal({destination: "/a", title: "t"}, link("(/a #{it})").first) }
  end

  def test_pointy_and_empty_destinations
    assert_equal({destination: "a b"}, link("(<a b>)").first)
    assert_equal({destination: ""}, link("(<>)").first)
    assert_equal({destination: ""}, link("()").first)
  end

  def test_spaces_may_include_one_line_ending
    assert_equal({destination: "/a", title: "t"}, link("(\n/a\n\"t\"\n)").first)
    assert_nil link("(<a\nb>)").first
  end

  def test_parentheses_balance_up_to_the_depth_limit
    nested = ->(depth) { "(#{"(" * depth}a#{")" * depth})" }

    assert_equal "(" * MAX_PAREN_DEPTH + "a" + ")" * MAX_PAREN_DEPTH, link(nested.call(MAX_PAREN_DEPTH)).first[:destination]
    assert_nil link(nested.call(MAX_PAREN_DEPTH + 1)).first
  end

  def test_a_title_needs_space_before_it
    assert_nil link('(<a>"t")').first
  end

  def test_the_scanner_is_untouched_on_failure
    ["(a b)", "(a", "(<a)", "(a \"t)", "x"].each { assert_equal [nil, it], link(it) }
  end

  private

  def link(source) = handled(source) { Zat::Markdown::InlineParser::LinkSyntax.inline_link(it) }
end
