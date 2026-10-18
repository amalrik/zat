# frozen_string_literal: true

require_relative "zat/version"
require_relative "zat/markdown"
require_relative "zat/terminal"
require_relative "zat/renderer"
require_relative "zat/cli"

module Zat
  def self.render(source, terminal:, theme: Renderer::Theme::DARK)
    Renderer.new(terminal:, theme:).render(Markdown.parse(source), capacity: source.bytesize * 2)
  end
end
