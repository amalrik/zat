# frozen_string_literal: true

module Zat
  module Markdown
    NO_ATTRS = {}.freeze
    NO_CHILDREN = [].freeze

    # A node of the Markdown AST. One class for every node type: `type` says
    # what it is, and the consumer dispatches with `case node.type`.
    # docs/adr/0001-own-parser.md lists the types and the attrs each one has.
    #
    #   type      Symbol, e.g. :heading, :text
    #   value     String for literal content (:text, :code, :code_block,
    #             :html_block, :html_inline), nil otherwise
    #   attrs     Hash of type-specific attributes, e.g. { level: 2 }
    #   children  Array of Node
    #   line      1-based source line where the node starts, nil for inlines
    #
    # Nodes are values: equal when their fields are equal, and deeply
    # shareable across Ractors once passed through Ractor.make_shareable.
    Node = Data.define(:type, :value, :attrs, :children, :line) do
      def initialize(type:, value: nil, attrs: NO_ATTRS, children: NO_CHILDREN, line: nil) = super
    end
  end
end
