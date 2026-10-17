# frozen_string_literal: true

module Zat
  module Markdown
    NO_ATTRS = {}.freeze
    NO_CHILDREN = [].freeze

    # Node types, their attrs and which carry a literal `value` are defined by
    # test/markdown/support/ast_schema.rb.
    Node = Data.define(:type, :value, :attrs, :children, :line) do
      def initialize(type:, value: nil, attrs: NO_ATTRS, children: NO_CHILDREN, line: nil) = super
    end
  end
end
