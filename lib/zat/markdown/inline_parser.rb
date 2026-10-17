# frozen_string_literal: true

module Zat
  module Markdown
    module InlineParser
      SOFTBREAK = Node.new(type: :softbreak)

      def self.parse(raw)
        return NO_CHILDREN if raw.empty?

        raw.split("\n").each_with_index.flat_map do |line, i|
          text = Node.new(type: :text, value: line.sub(/[ \t]+\z/, ""))
          i.zero? ? [text] : [SOFTBREAK, text]
        end
      end
    end
  end
end
