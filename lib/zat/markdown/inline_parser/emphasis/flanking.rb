# frozen_string_literal: true

module Zat
  module Markdown
    class InlineParser
      class Emphasis
        # The spec's flanking rules (6.2), given what surrounds a run: each
        # side is :whitespace (also either end of the text), :punctuation or
        # :other.
        Flanking = Data.define(:before, :after) do
          class << self
            def around(before, after) = new(before: kind(before), after: kind(after))

            private

            def kind(char)
              if char.nil? || char.match?(WHITESPACE) then :whitespace
              elsif char.match?(PUNCTUATION) then :punctuation
              else :other
              end
            end
          end

          def opens?(run)
            case run[0]
            when "_" then left_flanking? && (!right_flanking? || before == :punctuation)
            when STRIKETHROUGH then left_flanking? && run.size <= MAX_TILDES
            else left_flanking?
            end
          end

          def closes?(run)
            case run[0]
            when "_" then right_flanking? && (!left_flanking? || after == :punctuation)
            when STRIKETHROUGH then right_flanking? && run.size <= MAX_TILDES
            else right_flanking?
            end
          end

          private

          def left_flanking?
            return false if after == :whitespace
            return true unless after == :punctuation

            before == :whitespace || before == :punctuation
          end

          def right_flanking?
            return false if before == :whitespace
            return true unless before == :punctuation

            after == :whitespace || after == :punctuation
          end
        end
      end
    end
  end
end
