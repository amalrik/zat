# frozen_string_literal: true

require_relative "zat/version"
require_relative "zat/markdown"
require_relative "zat/terminal"
require_relative "zat/renderer"
require_relative "zat/cli"

module Zat
  # Escape sequences roughly double the source size; unmeasured until #24.
  OUTPUT_CAPACITY_FACTOR = 2

  def self.render(source, terminal:, theme: Renderer::Theme::DARK)
    Renderer.new(terminal:, theme:).render(Markdown.parse(source), capacity: source.bytesize * OUTPUT_CAPACITY_FACTOR)
  end
end
