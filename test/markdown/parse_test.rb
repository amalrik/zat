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

  def test_code_blocks_record_how_they_were_written
    fenced, indented = Zat::Markdown.parse("```ruby  \nputs 1\n```\n\n    x = 1\n").children

    assert_equal({fenced: true, info: "ruby"}, fenced.attrs)
    assert_equal [1, 5], [fenced.line, indented.line]
    assert_equal({fenced: false}, indented.attrs)
  end

  # The spec only exercises partial tabs inside list items, which aren't parsed yet.
  def test_a_partly_consumed_tab_leaves_its_remaining_width_as_spaces
    assert_equal "  foo\n", Zat::Markdown.parse("  ```\n\tfoo\n  ```\n").children.first.value
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

  # A constant that is merely frozen (say, a frozen Hash of Arrays) only fails once a Ractor reads it.
  def test_every_constant_is_shareable
    namespaces = [Zat::Markdown] + Zat::Markdown.constants.map { Zat::Markdown.const_get(it) }.grep(Module)
    unshareable = namespaces.flat_map do |namespace|
      namespace.constants.reject { Ractor.shareable?(namespace.const_get(it)) }.map { "#{namespace}::#{it}" }
    end

    assert_empty unshareable
  end

  def test_parses_inside_a_ractor
    # Every construct here reads constants (entities, regexps, shared nodes), which must be shareable.
    source = "# a\n\nb  \nc\xFF `x` &ouml; &#42; \\* <b> <!-- c --> <https://a.b>\n\n```r&amp;\n```\n"
    expected = Zat::Markdown.parse(source)

    assert_equal expected, Ractor.new(source) { Zat::Markdown.parse(it) }.value
  end

  # Spec examples cover behavior; this covers inputs nobody wrote by hand.
  def test_random_input_never_breaks_the_parser
    alphabet = ["#", "*", "-", "_", "=", "+", ">", "`", "~", "|", "[", "]", "(", ")", "!", "<", "&", "\\",
      "1", ".", "a", "é", " ", " ", "\t", "\n", "\n", "\r", "\0", "\xFF", ";", ":", "@", "/", "?", "x"]
    random = Random.new(20261017)

    300.times do
      source = Array.new(random.rand(0..200)) { alphabet.sample(random:) }.join
      assert_valid_ast Zat::Markdown.parse(source)
    end
  end

  private

  def first_text(source) = Zat::Markdown.parse(source).children.first.children.first.value
end
