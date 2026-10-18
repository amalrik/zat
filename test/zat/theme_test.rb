# frozen_string_literal: true

require "test_helper"
require "zat"

class ThemeTest < Minitest::Test
  def test_looks_up_styles_by_element
    assert_predicate Zat::Theme::DARK[:strong], :bold
  end

  def test_unknown_elements_fail_loudly
    assert_raises(KeyError) { Zat::Theme::DARK[:nope] }
  end

  def test_is_shareable
    assert Ractor.shareable?(Zat::Theme::DARK)
  end
end
