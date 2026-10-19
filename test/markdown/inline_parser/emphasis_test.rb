# frozen_string_literal: true

require "test_helper"
require "zat/markdown"

# The algorithm on hand-built items: text nodes and delimiter runs.
class EmphasisTest < Minitest::Test
  Emphasis = Zat::Markdown::InlineParser::Emphasis
  Node = Zat::Markdown::Node

  def test_a_run_of_two_makes_strong_and_one_makes_emph
    assert_equal [[:strong, [[:text, "a"]]]], tree(run_of("**", " ", "a"), "a", run_of("**", "a", nil))
    assert_equal [[:emph, [[:text, "a"]]]], tree(run_of("*", nil, "a"), "a", run_of("*", "a", nil))
  end

  def test_unmatched_runs_merge_with_their_neighbours
    assert_equal [[:text, "a*b"]], tree("a", run_of("*", " ", "b"), "b")
  end

  def test_leftovers_stay_on_the_outside
    assert_equal [[:text, "*"], [:strong, [[:text, "a"]]]], tree(run_of("***", nil, "a"), "a", run_of("**", "a", nil))
  end

  def test_the_rule_of_three_keeps_these_apart
    # *a**b*: the inner run can open and close, and 1 + 2 is a multiple of 3.
    items = [run_of("*", nil, "a"), "a", run_of("**", "a", "b"), "b", run_of("*", "b", nil)]

    assert_equal [[:emph, [[:text, "a**b"]]]], tree(*items)
  end

  def test_strikethrough_needs_runs_of_the_same_length
    assert_equal [[:strikethrough, [[:text, "a"]]]], tree(run_of("~~", nil, "a"), "a", run_of("~~", "a", nil))
    assert_equal [[:text, "~~a~"]], tree(run_of("~~", nil, "a"), "a", run_of("~", "a", nil))
  end

  def test_delimiter_text_is_what_matching_left
    delimiter = Emphasis::Delimiter.for("***", nil, "a")
    delimiter.remaining = 1

    assert_equal "*", delimiter.text
  end

  private

  def run_of(characters, before, after) = Emphasis::Delimiter.for(characters, before, after)

  def tree(*items)
    nodes = items.map { it.is_a?(String) ? Node.new(type: :text, value: it) : it }
    shape(Emphasis.process(nodes))
  end

  def shape(nodes) = nodes.map { (it.type == :text) ? [:text, it.value] : [it.type, shape(it.children)] }
end
