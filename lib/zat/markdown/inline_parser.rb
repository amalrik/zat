# frozen_string_literal: true

module Zat
  module Markdown
    module InlineParser
      SOFTBREAK = Node.new(type: :softbreak)

      def self.parse(raw)
        return NO_CHILDREN if raw.empty?

        texts = raw.split("\n").map { Node.new(type: :text, value: it.sub(/[ \t]+\z/, "")) }
        texts.flat_map { [SOFTBREAK, it] }.drop(1)
      end
    end
  end
end
