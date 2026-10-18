# frozen_string_literal: true

module Zat
  Theme = Data.define(:name, :styles) do
    def [](element) = styles.fetch(element)
  end

  Theme::DARK = Ractor.make_shareable(Theme.new(name: :dark, styles: {
    heading_1: Style.new(fg: 0x61AFEF, bold: true, underline: true),
    heading_2: Style.new(fg: 0x61AFEF, bold: true),
    heading: Style.new(fg: 0x56B6C2, bold: true),
    strong: Style.new(bold: true),
    emph: Style.new(italic: true),
    strikethrough: Style.new(strike: true),
    code: Style.new(fg: 0xE5C07B),
    code_block: Style.new(fg: 0xABB2BF),
    code_block_gutter: Style.new(fg: 0x5C6370),
    block_quote: Style.new(fg: 0x5C6370, italic: true),
    thematic_break: Style.new(fg: 0x5C6370),
    list_marker: Style.new(fg: 0xE06C75),
    link: Style.new(fg: 0x61AFEF, underline: true),
    html: Style.new(dim: true)
  }))
end
