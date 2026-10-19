# frozen_string_literal: true

require "test_helper"
require "zat/markdown"
require_relative "../support/scanning"

class RawHTMLTest < Minitest::Test
  include Scanning

  def test_tags_comments_and_other_constructs
    ['<a href="x">', "</a >", "<!-- c -->", "<?php ?>", "<![CDATA[x]]>", "<!DOCTYPE html>"].each do |html|
      node, rest = raw_html("#{html} after")

      assert_equal [:html_inline, html], [node.type, node.value]
      assert_equal " after", rest
    end
  end

  def test_attributes_may_span_one_line_ending
    assert_equal "<a\nb>", raw_html("<a\nb>").first.value
    assert_nil raw_html("<a\n\nb>").first
  end

  def test_nothing_is_consumed_when_it_is_not_html
    ["<a b=>", "< a>", "<!-- open"].each { assert_equal [nil, it], raw_html(it) }
  end

  def test_an_unterminated_construct_stays_unterminated
    s = scanner("<!-- a <!-- b")
    html = Zat::Markdown::InlineParser::RawHTML.new(s)

    assert_nil html.scan
    s.pos = 7

    assert_nil html.scan
  end

  private

  def raw_html(source) = handled(source) { Zat::Markdown::InlineParser::RawHTML.new(it).scan }
end
