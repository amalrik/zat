# frozen_string_literal: true

require "test_helper"
require "zat"

class TerminalTest < Minitest::Test
  FakeIO = Data.define(:tty, :winsize) do
    def tty? = tty
  end

  TTY = FakeIO.new(tty: true, winsize: [24, 120])
  PIPE = FakeIO.new(tty: false, winsize: [0, 0])

  def test_color_depth_follows_the_terminal
    assert_equal :truecolor, depth(TTY, {"COLORTERM" => "truecolor"})
    assert_equal :truecolor, depth(TTY, {"COLORTERM" => "24bit"})
    assert_equal :ansi256, depth(TTY, {"TERM" => "xterm-256color"})
    assert_equal :ansi16, depth(TTY, {"TERM" => "xterm"})
  end

  def test_no_color_when_piped_dumb_or_asked_not_to
    assert_equal :none, depth(PIPE, {"COLORTERM" => "truecolor"})
    assert_equal :none, depth(TTY, {"TERM" => "dumb"})
    assert_equal :none, depth(TTY, {"NO_COLOR" => "1", "COLORTERM" => "truecolor"})
    assert_equal :none, depth(TTY, {"COLORTERM" => "truecolor"}, color: :never)
  end

  def test_an_empty_no_color_is_ignored
    assert_equal :truecolor, depth(TTY, {"NO_COLOR" => "", "COLORTERM" => "truecolor"})
  end

  def test_color_always_overrides_no_color_and_pipes
    assert_equal :ansi256, depth(PIPE, {"NO_COLOR" => "1", "TERM" => "xterm-256color"}, color: :always)
  end

  def test_columns_come_from_the_tty_then_columns_then_80
    assert_equal 120, Zat::Terminal.detect(io: TTY, env: {"COLUMNS" => "60"}).columns
    assert_equal 60, Zat::Terminal.detect(io: PIPE, env: {"COLUMNS" => "60"}).columns
    assert_equal 80, Zat::Terminal.detect(io: PIPE, env: {}).columns
    assert_equal 80, Zat::Terminal.detect(io: StringIO.new, env: {}).columns
  end

  def test_is_shareable
    assert Ractor.shareable?(Zat::Terminal.detect(io: TTY, env: {}))
  end

  private

  def depth(io, env, color: :auto) = Zat::Terminal.detect(io:, env:, color:).color_depth
end
