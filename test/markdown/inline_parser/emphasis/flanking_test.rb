# frozen_string_literal: true

require "test_helper"
require "zat/markdown"

# The examples under the spec's definitions of left- and right-flanking runs.
class FlankingTest < Minitest::Test
  Flanking = Zat::Markdown::InlineParser::Emphasis::Flanking

  def test_both_ends_of_the_text_count_as_whitespace
    assert_equal [true, false], flanks("*", nil, "a")
    assert_equal [false, true], flanks("*", "a", nil)
    assert_equal [false, false], flanks("*", nil, nil)
  end

  def test_asterisks_open_and_close_inside_words
    assert_equal [true, true], flanks("*", "a", "b")
    assert_equal [false, false], flanks("*", " ", " ")
  end

  def test_punctuation_needs_space_or_punctuation_on_the_other_side
    assert_equal [false, true], flanks("**", "a", '"')
    assert_equal [true, false], flanks("**", " ", '"')
    assert_equal [true, true], flanks("*", ")", "(")
  end

  def test_underscores_do_not_open_or_close_inside_words
    assert_equal [false, false], flanks("_", "a", "b")
    assert_equal [true, true], flanks("_", ")", "(")
    assert_equal [true, false], flanks("_", " ", "a")
  end

  def test_unicode_whitespace_and_symbols
    assert_equal [false, false], flanks("*", " ", " ")
    assert_equal [true, false], flanks("*", " ", "€")
  end

  def test_tildes_strike_with_one_or_two_only
    assert_equal [true, false], flanks("~~", " ", "a")
    assert_equal [false, false], flanks("~~~", " ", "a")
  end

  private

  def flanks(run, before, after)
    flanking = Flanking.around(before, after)
    [flanking.opens?(run), flanking.closes?(run)]
  end
end
