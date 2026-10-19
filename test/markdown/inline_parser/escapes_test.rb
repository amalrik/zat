# frozen_string_literal: true

require "test_helper"
require "zat/markdown"
require_relative "../support/scanning"

class EscapesTest < Minitest::Test
  include Scanning

  Escapes = Zat::Markdown::InlineParser::Escapes

  def test_named_decimal_and_hex_entities_decode
    assert_equal ["ö", " x"], entity("&ouml; x")
    assert_equal ["*", ""], entity("&#42;")
    assert_equal ["©", ""], entity("&#xA9;")
  end

  def test_invalid_codepoints_become_the_replacement_character
    ["&#0;", "&#xD800;", "&#x110000;"].each { assert_equal ["�", ""], entity(it) }
  end

  def test_anything_else_is_a_literal_ampersand
    assert_equal ["&", "nope;"], entity("&nope;")
    assert_equal ["&", "ouml"], entity("&ouml")
    assert_equal ["&", "#x;"], entity("&#x;")
  end

  def test_unescape_handles_escapes_and_entities_only
    assert_equal "a*b&ö&nope;*", Escapes.unescape("a\\*b&amp;&ouml;&nope;*")
    assert_equal "\\a *b*", Escapes.unescape("\\a *b*")
  end

  private

  def entity(source) = handled(source) { Escapes.entity(it) }
end
