# frozen_string_literal: true

module Zat
  module Markdown
    class InlineParser
      class Emphasis
        # Mutable on purpose: matching consumes a run from the inside out.
        Delimiter = Struct.new(:char, :length, :can_open, :can_close, :remaining, :position) do
          # `before` and `after` are the characters around the run, nil at
          # either end of the text.
          def self.for(run, before, after)
            flanking = Flanking.around(before, after)
            new(char: run[0], length: run.size, can_open: flanking.opens?(run), can_close: flanking.closes?(run), remaining: run.size)
          end

          def text = char * remaining

          # Closers with the same key fail against the same openers.
          def bottom_key = [char, can_open, length % RULE_OF_THREE]
        end
      end
    end
  end
end
