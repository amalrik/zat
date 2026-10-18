# frozen_string_literal: true

module Zat
  class Terminal
    # Colors are 0xRRGGBB integers, downsampled to what the terminal supports.
    Style = Data.define(:fg, :bg, :bold, :dim, :italic, :underline, :strike) do
      def initialize(fg: nil, bg: nil, bold: false, dim: false, italic: false, underline: false, strike: false) = super

      def open(depth)
        return "" if depth == :none

        codes = attribute_codes + color_codes(fg, depth, background: false) + color_codes(bg, depth, background: true)
        codes.empty? ? "" : "\e[#{codes.join(";")}m"
      end

      def close(depth) = (depth == :none || plain?) ? "" : "\e[0m"

      def plain? = to_h.values.none?

      private

      def attribute_codes
        [[bold, 1], [dim, 2], [italic, 3], [underline, 4], [strike, 9]].filter_map { |on, code| code if on }
      end

      def color_codes(rgb, depth, background:)
        return [] unless rgb

        case depth
        when :truecolor then [background ? 48 : 38, 2, *Palette.channels(rgb)]
        when :ansi256 then [background ? 48 : 38, 5, Palette.xterm256(rgb)]
        when :ansi16 then [Palette.ansi16(rgb) + (background ? 10 : 0)]
        end
      end
    end
  end
end
