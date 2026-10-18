# frozen_string_literal: true

module Zat
  module Markdown
    class InlineParser
      # The spec's "process emphasis" (section 6.2), plus GFM strikethrough, in
      # one pass: a closer can only match openers to its left, so each run is
      # settled as soon as it is reached.
      class Emphasis
        STRIKETHROUGH = "~"
        MAX_TILDES = 2
        STRONG = 2
        TYPES = Ractor.make_shareable({1 => :emph, STRONG => :strong})
        # Rules 9 and 10 compare run lengths modulo 3.
        RULE_OF_THREE = 3
        WHITESPACE = /[\p{Zs}\t\n\f\r]/
        PUNCTUATION = /[\p{P}\p{S}]/

        # Mutable on purpose: matching consumes a run from the inside out.
        Delimiter = Struct.new(:char, :length, :can_open, :can_close, :remaining, :position) do
          class << self
            # `before` and `after` are the characters around the run, nil at
            # either end of the text.
            def for(run, before, after)
              before, after = flank(before), flank(after)
              left = after != :whitespace && (after != :punctuation || before != :other)
              right = before != :whitespace && (before != :punctuation || after != :other)
              can_open, can_close =
                case run[0]
                when "_" then [left && (!right || before == :punctuation), right && (!left || after == :punctuation)]
                when STRIKETHROUGH then (run.size <= MAX_TILDES) ? [left, right] : [false, false]
                else [left, right]
                end
              new(char: run[0], length: run.size, can_open:, can_close:, remaining: run.size)
            end

            private

            def flank(char)
              if char.nil? || char.match?(WHITESPACE) then :whitespace
              elsif char.match?(PUNCTUATION) then :punctuation
              else :other
              end
            end
          end

          def text = char * remaining

          # Closers with the same key fail against the same openers.
          def bottom_key = [char, can_open, length % RULE_OF_THREE]
        end

        def self.process(items) = new.process(items)

        def initialize
          @out = []
          @openers = []
          @bottoms = Hash.new(0)
        end

        def process(items)
          items.each { it.is_a?(Delimiter) ? delimiter(it) : @out << it }
          finish(@out)
        end

        private

        def delimiter(run)
          close(run) if run.can_close
          return if run.remaining.zero?

          if run.can_open
            run.position = @out.size
            @openers << run
          end
          @out << run
        end

        def close(closer)
          while closer.remaining.positive? && (index = opener_index(closer))
            opener = @openers[index]
            used = consumed(opener, closer)
            opener.remaining -= used
            closer.remaining -= used

            children = finish(@out.slice!(opener.position + 1..))
            if opener.remaining.zero?
              @out.pop
              truncate(index)
            else
              truncate(index + 1)
            end
            @out << Node.new(type: (opener.char == STRIKETHROUGH) ? :strikethrough : TYPES.fetch(used), children:)
          end
        end

        def opener_index(closer)
          key = closer.bottom_key
          index = (@openers.size - 1).downto(@bottoms[key]).find { matches?(@openers[it], closer) }
          @bottoms[key] = @openers.size unless index
          index
        end

        def matches?(opener, closer)
          return false unless opener.char == closer.char
          return opener.length == closer.length if opener.char == STRIKETHROUGH

          !(opener.can_close || closer.can_open) || (closer.length % RULE_OF_THREE).zero? ||
            !((opener.length + closer.length) % RULE_OF_THREE).zero?
        end

        def consumed(opener, closer)
          return closer.remaining if opener.char == STRIKETHROUGH

          (opener.remaining >= STRONG && closer.remaining >= STRONG) ? STRONG : 1
        end

        # Openers between a match are dropped, and bottoms above the new top
        # would hide openers pushed later.
        def truncate(size)
          @openers.slice!(size..)
          @bottoms.transform_values! { [it, size].min }
        end

        # Unmatched runs are literal text, merged with their neighbours.
        def finish(items)
          items.chunk_while { text?(_1) && text?(_2) }.map do |run|
            next run.first if run in [Node]

            Node.new(type: :text, value: run.map { it.is_a?(Delimiter) ? it.text : it.value }.join)
          end
        end

        def text?(item) = item.is_a?(Delimiter) || item.type == :text
      end
    end
  end
end
