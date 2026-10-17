# frozen_string_literal: true

require "test_helper"
require "zat"

class StyleTest < Minitest::Test
  RED_BOLD = Zat::Style.new(fg: 0xFF0000, bold: true)

  def test_open_per_color_depth
    assert_equal "\e[1;38;2;255;0;0m", RED_BOLD.open(:truecolor)
    assert_equal "\e[1;38;5;196m", RED_BOLD.open(:ansi256)
    assert_equal "\e[1;91m", RED_BOLD.open(:ansi16)
    assert_equal "", RED_BOLD.open(:none)
  end

  def test_background_and_attributes
    style = Zat::Style.new(bg: 0x000000, dim: true, italic: true, underline: true, strike: true)

    assert_equal "\e[2;3;4;9;48;2;0;0;0m", style.open(:truecolor)
    assert_equal "\e[2;3;4;9;40m", style.open(:ansi16)
  end

  def test_close_resets_only_when_something_was_opened
    assert_equal "\e[0m", RED_BOLD.close(:ansi16)
    assert_equal "", RED_BOLD.close(:none)
    assert_equal "", Zat::Style.new.close(:truecolor)
  end

  def test_xterm256_picks_the_cube_or_the_gray_ramp
    assert_equal 16, Zat::Palette.xterm256(0x000000)
    assert_equal 196, Zat::Palette.xterm256(0xFF0000)
    assert_equal 231, Zat::Palette.xterm256(0xFFFFFF)
    assert_equal 244, Zat::Palette.xterm256(0x808080)
    assert_equal 75, Zat::Palette.xterm256(0x61AFEF)
  end

  def test_ansi16_picks_the_nearest_basic_color
    assert_equal 30, Zat::Palette.ansi16(0x000000)
    assert_equal 91, Zat::Palette.ansi16(0xFF0000)
    assert_equal 90, Zat::Palette.ansi16(0x808080)
    assert_equal 97, Zat::Palette.ansi16(0xFFFFFF)
  end

  def test_no_ansi_escapes_outside_style_rb
    lib = File.expand_path("../../lib", __dir__)
    offenders = Dir["#{lib}/**/*.rb"].reject { it.end_with?("/style.rb") }.select { File.read(it).include?('\e[') }

    assert_empty offenders.map { it.delete_prefix("#{lib}/") }
  end
end
