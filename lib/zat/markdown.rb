# frozen_string_literal: true

require_relative "markdown/node"
require_relative "markdown/inline_parser"
require_relative "markdown/block_parser"

module Zat
  # Meant to become its own gem: must not require anything else from Zat.
  module Markdown
    def self.parse(source) = Ractor.make_shareable(BlockParser.parse(source))
  end
end
