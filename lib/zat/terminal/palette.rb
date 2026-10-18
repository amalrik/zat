# frozen_string_literal: true

module Zat
  class Terminal
    module Palette
      CUBE_LEVELS = [0, 95, 135, 175, 215, 255].freeze
      # xterm's default RGB for the 16 basic colors, with their SGR foreground codes.
      BASIC = {
        30 => 0x000000, 31 => 0xCD0000, 32 => 0x00CD00, 33 => 0xCDCD00,
        34 => 0x0000EE, 35 => 0xCD00CD, 36 => 0x00CDCD, 37 => 0xE5E5E5,
        90 => 0x7F7F7F, 91 => 0xFF0000, 92 => 0x00FF00, 93 => 0xFFFF00,
        94 => 0x5C5CFF, 95 => 0xFF00FF, 96 => 0x00FFFF, 97 => 0xFFFFFF
      }.freeze

      class << self
        def channels(rgb) = [(rgb >> 16) & 0xFF, (rgb >> 8) & 0xFF, rgb & 0xFF]

        # Nearest of the 6×6×6 color cube (16–231) and the gray ramp (232–255).
        def xterm256(rgb)
          color = channels(rgb)
          cube = color.map { |v| CUBE_LEVELS.each_index.min_by { (CUBE_LEVELS[it] - v).abs } }
          gray_step = ((color.sum / 3.0 - 8) / 10).round.clamp(0, 23)
          candidates = {
            16 + 36 * cube[0] + 6 * cube[1] + cube[2] => cube.map { CUBE_LEVELS[it] },
            232 + gray_step => [8 + 10 * gray_step] * 3
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
