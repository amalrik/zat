# frozen_string_literal: true

require "test_helper"
require "zat/markdown"
require_relative "../support/scanning"

class AutolinksTest < Minitest::Test
  include Scanning

  def test_uri
    link, rest = autolink("<https://a.b/c?d> e")

    assert_equal({destination: "https://a.b/c?d", autolink: true}, link.attrs)
    assert_equal [[:text, "https://a.b/c?d"]], link.children.map { [it.type, it.value] }
    assert_equal " e", rest
  end

  def test_email_gets_mailto
    link, = autolink("<dev@example.com>")

    assert_equal "mailto:dev@example.com", link.attrs[:destination]
    assert_equal "dev@example.com", link.children.first.value
  end

  def test_nothing_is_consumed_otherwise
    ["<a b>", "<https://a b>", "<x:", "<@a.b>"].each { assert_equal [nil, it], autolink(it) }
  end

  private

  def autolink(source) = handled(source) { Zat::Markdown::InlineParser::Autolinks.scan(it) }
end
