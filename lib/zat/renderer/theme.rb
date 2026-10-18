# frozen_string_literal: true

module Zat
  class Renderer
    Theme = Data.define(:name, :styles) do
      def [](element) = styles.fetch(element)
    end

    Theme::DARK = Ractor.make_shareable(Theme.new(name: :dark, styles: {
      heading_1: Terminal::Style.new(fg: 0x61AFEF, bold: true),
      heading_2: Terminal::Style.new(fg: 0x61AFEF, bold: true),
      heading: Terminal::Style.new(fg: 0x56B6C2, bold: true),
      strong: Terminal::Style.new(bold: true),
      emph: Terminal::Style.new(italic: true),
      strikethrough: Terminal::Style.new(strike: true),
      code: Terminal::Style.new(fg: 0xE5C07B),
      code_block: Terminal::Style.new(fg: 0xABB2BF),
      code_block_gutter: Terminal::Style.new(fg: 0x5C6370),
      block_quote: Terminal::Style.new(fg: 0x5C6370, italic: true),
      thematic_break: Terminal::Style.new(fg: 0x5C6370),
      list_marker: Terminal::Style.new(fg: 0xE06C75),
      link: Terminal::Style.new(fg: 0x61AFEF, underline: true),
      html: Terminal::Style.new(dim: true)
    }))
  end
end
