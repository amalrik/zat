# frozen_string_literal: true

module Zat
  class Terminal
    # Select Graphic Rendition parameters (ECMA-48 §8.3.117).
    module SGR
      RESET = 0
      ATTRIBUTES = {bold: 1, dim: 2, italic: 3, underline: 4, strike: 9}.freeze
      FOREGROUND = 38
      BACKGROUND = 48
      INDEXED = 5
      TRUECOLOR = 2
      # 30–37/90–97 become 40–47/100–107.
      BACKGROUND_OFFSET = 10

      def self.sequence(codes) = "\e[#{codes.join(";")}m"
    end

    # Colors are 0xRRGGBB integers, downsampled to what the terminal supports.
    Style = Data.define(:fg, :bg, :bold, :dim, :italic, :underline, :strike) do
      def initialize(fg: nil, bg: nil, bold: false, dim: false, italic: false, underline: false, strike: false) = super

      def self.reset(depth) = (depth == :none) ? "" : SGR.sequence([SGR::RESET])

      def open(depth)
        return "" if depth == :none

        codes = attribute_codes + color_codes(fg, depth, background: false) + color_codes(bg, depth, background: true)
        codes.empty? ? "" : SGR.sequence(codes)
      end

      def close(depth) = plain? ? "" : self.class.reset(depth)

      def plain? = to_h.values.none?

      private

      def attribute_codes = SGR::ATTRIBUTES.filter_map { |name, code| code if public_send(name) }

      def color_codes(rgb, depth, background:)
        return [] unless rgb

        target = background ? SGR::BACKGROUND : SGR::FOREGROUND
        case depth
        when :truecolor then [target, SGR::TRUECOLOR, *Palette.channels(rgb)]
        when :ansi256 then [target, SGR::INDEXED, Palette.xterm256(rgb)]
        when :ansi16 then [Palette.ansi16(rgb) + (background ? SGR::BACKGROUND_OFFSET : 0)]
        end
      end
    end
  end
end
