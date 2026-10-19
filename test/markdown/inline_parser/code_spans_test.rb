# frozen_string_literal: true

require "test_helper"
require "zat/markdown"
require_relative "../support/scanning"

class CodeSpansTest < Minitest::Test
  include Scanning

  def test_the_closer_is_a_run_of_the_same_length
    code, rest = code_span("``a ` b`` c")

    assert_equal "a ` b", code.value
    assert_equal " c", rest
  end

  def test_one_space_on_each_side_is_stripped_unless_all_spaces
    assert_equal " a ", code_span("`  a  `").first.value
    assert_equal "  ", code_span("`  `").first.value
  end

  def test_line_endings_become_spaces
    assert_equal "a b", code_span("`a\nb`").first.value
  end

  def test_without_a_closer_the_whole_run_is_text
    assert_equal ["``", "a`"], code_span("``a`")
  end

  def test_a_closer_already_passed_does_not_count
    s = scanner("`a` ``b")
    spans = Zat::Markdown::InlineParser::CodeSpans.new(s)

    assert_equal "a", spans.scan.value
    s.pos += 1

    assert_equal "``", spans.scan
  end

  private

  def code_span(source) = handled(source) { Zat::Markdown::InlineParser::CodeSpans.new(it).scan }
end
