# frozen_string_literal: true

require "test_helper"
require "zat"

class PaletteTest < Minitest::Test
  def test_xterm256_picks_the_cube_or_the_gray_ramp
    assert_equal 16, Zat::Terminal::Palette.xterm256(0x000000)
    assert_equal 196, Zat::Terminal::Palette.xterm256(0xFF0000)
    assert_equal 231, Zat::Terminal::Palette.xterm256(0xFFFFFF)
    assert_equal 244, Zat::Terminal::Palette.xterm256(0x808080)
    assert_equal 75, Zat::Terminal::Palette.xterm256(0x61AFEF)
  end

  def test_ansi16_picks_the_nearest_basic_color
    assert_equal 30, Zat::Terminal::Palette.ansi16(0x000000)
    assert_equal 91, Zat::Terminal::Palette.ansi16(0xFF0000)
    assert_equal 90, Zat::Terminal::Palette.ansi16(0x808080)
    assert_equal 97, Zat::Terminal::Palette.ansi16(0xFFFFFF)
  end
end
