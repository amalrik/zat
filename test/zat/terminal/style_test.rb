# frozen_string_literal: true

require "test_helper"
require "zat"

class StyleTest < Minitest::Test
  RED_BOLD = Zat::Terminal::Style.new(fg: 0xFF0000, bold: true)

  def test_open_per_color_depth
    assert_equal "\e[1;38;2;255;0;0m", RED_BOLD.open(:truecolor)
    assert_equal "\e[1;38;5;196m", RED_BOLD.open(:ansi256)
    assert_equal "\e[1;91m", RED_BOLD.open(:ansi16)
    assert_equal "", RED_BOLD.open(:none)
  end

  def test_background_and_attributes
    style = Zat::Terminal::Style.new(bg: 0x000000, dim: true, italic: true, underline: true, strike: true)

    assert_equal "\e[2;3;4;9;48;2;0;0;0m", style.open(:truecolor)
    assert_equal "\e[2;3;4;9;40m", style.open(:ansi16)
  end

  def test_close_resets_only_when_something_was_opened
    assert_equal "\e[0m", RED_BOLD.close(:ansi16)
    assert_equal "", RED_BOLD.close(:none)
    assert_equal "", Zat::Terminal::Style.new.close(:truecolor)
  end

  def test_no_ansi_escapes_outside_this_file
    lib = File.expand_path("../../../lib", __dir__)
    offenders = Dir["#{lib}/**/*.rb"].reject { it.end_with?("/terminal/style.rb") }.select { File.read(it).include?('\e[') }

    assert_empty offenders.map { it.delete_prefix("#{lib}/") }
  end
end
