# frozen_string_literal: true

require "test_helper"
require "zat/markdown"
require_relative "support/ast_schema"

class ParseTest < Minitest::Test
  include ASTAssertions

  def test_blocks_record_their_source_line
    lines = Zat::Markdown.parse("# Title\n\nsome\ntext\n\n---\n").children.map { [it.type, it.line] }

    assert_equal [[:heading, 1], [:paragraph, 3], [:thematic_break, 6]], lines
  end

  def test_setext_heading_keeps_the_paragraph_line
    assert_equal 1, Zat::Markdown.parse("Title\n=====\n").children.first.line
  end

  def test_line_endings_are_normalized
    assert_equal Zat::Markdown.parse("a\nb\nc\n"), Zat::Markdown.parse("a\r\nb\rc\r\n")
  end

  def test_invalid_utf8_becomes_the_replacement_character
    assert_equal "caf\u{FFFD}", first_text("caf\xE9\n")
  end

  def test_binary_input_is_read_as_utf8
    assert_equal "café", first_text("café\n".b)
  end

  def test_other_encodings_are_transcoded
    assert_equal "café", first_text("café\n".encode("ISO-8859-1"))
  end

  def test_the_tree_is_deeply_frozen
    assert Ractor.shareable?(Zat::Markdown.parse("# a\n\nb\nc\n"))
  end

  def test_parses_inside_a_ractor
    assert_equal 2, Ractor.new { Zat::Markdown.parse("# a\n\nb\n").children.size }.value
  end

  # Spec examples cover behavior; this covers inputs nobody wrote by hand.
  def test_random_input_never_breaks_the_parser
    alphabet = ["#", "*", "-", "_", "=", "+", ">", "`", "~", "|", "[", "]", "(", ")", "!", "<", "&", "\\",
      "1", ".", "a", "é", " ", " ", "\t", "\n", "\n", "\r", "\0", "\xFF"]
    random = Random.new(20261017)

    300.times do
      source = Array.new(random.rand(0..200)) { alphabet.sample(random:) }.join
      assert_valid_ast Zat::Markdown.parse(source)
    end
  end

  private

  def first_text(source) = Zat::Markdown.parse(source).children.first.children.first.value
end
