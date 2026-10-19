# frozen_string_literal: true

module Zat
  module Terminal
    module Palette
      # xterm's 256-color layout: 16 basic colors, a 6×6×6 cube, then 24 grays (8, 18 … 238).
      CUBE_START = 16
      CUBE_LEVELS = [0, 95, 135, 175, 215, 255].freeze
      GRAY_START = 232
      GRAY_COUNT = 24
      GRAY_FIRST = 8
      GRAY_STEP = 10
      # xterm's default RGB for the 16 basic colors, with their SGR foreground codes.
      BASIC = {
        30 => 0x000000, 31 => 0xCD0000, 32 => 0x00CD00, 33 => 0xCDCD00,
        34 => 0x0000EE, 35 => 0xCD00CD, 36 => 0x00CDCD, 37 => 0xE5E5E5,
        90 => 0x7F7F7F, 91 => 0xFF0000, 92 => 0x00FF00, 93 => 0xFFFF00,
        94 => 0x5C5CFF, 95 => 0xFF00FF, 96 => 0x00FFFF, 97 => 0xFFFFFF
      }.freeze

      class << self
        def channels(rgb) = [(rgb >> 16) & 0xFF, (rgb >> 8) & 0xFF, rgb & 0xFF]

        # Nearest of the color cube and the gray ramp.
        def xterm256(rgb)
          color = channels(rgb)
          cube = color.map { |v| CUBE_LEVELS.each_index.min_by { (CUBE_LEVELS[it] - v).abs } }
          gray = ((color.sum.fdiv(color.size) - GRAY_FIRST) / GRAY_STEP).round.clamp(0, GRAY_COUNT - 1)
          candidates = {
            CUBE_START + cube.reduce(0) { |index, level| index * CUBE_LEVELS.size + level } => cube.map { CUBE_LEVELS[it] },
            GRAY_START + gray => [GRAY_FIRST + GRAY_STEP * gray] * color.size
          }
          candidates.min_by { |_, candidate| distance(color, candidate) }.first
        end

        def ansi16(rgb) = BASIC.min_by { |_, basic| distance(channels(rgb), channels(basic)) }.first

        private

        def distance(a, b) = a.zip(b).sum { |x, y| (x - y)**2 }
      end
    end
  end
end
