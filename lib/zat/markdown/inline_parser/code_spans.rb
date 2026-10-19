# frozen_string_literal: true

module Zat
  module Markdown
    class InlineParser
      # Spec section 6.1. The closer is the next run of exactly as many
      # backticks. Every run's last position is known up front, so a missing
      # closer costs nothing.
      class CodeSpans
        BACKTICKS = /`+/

        def initialize(scanner)
          @scanner = scanner
          # Set up front so every instance has the same shape.
          @last_run = nil
        end

        # A :code node, or the backticks as literal text when nothing closes them.
        def scan
          opener = @scanner.scan(BACKTICKS)
          content = @scanner.scan_until(/(?<!`)#{opener}(?!`)/) if closer_ahead?(opener)
          content ? Node.new(type: :code, value: code(content.delete_suffix(opener))) : opener
        end

        private

        def closer_ahead?(opener)
          last = last_run[opener.size]
          !last.nil? && last >= @scanner.pos
        end

        def last_run
          @last_run ||= begin
            runs = {}
            @scanner.string.scan(BACKTICKS) { runs[it.size] = Regexp.last_match.byteoffset(0).first }
            runs
          end
        end

        def code(content)
          content = content.tr("\n", " ")
          stripped = content.start_with?(" ") && content.end_with?(" ") && !content.match?(/\A +\z/)
          stripped ? content[1..-2] : content
        end
      end
    end
  end
end
