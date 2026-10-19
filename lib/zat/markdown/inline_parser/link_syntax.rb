# frozen_string_literal: true

module Zat
  module Markdown
    class InlineParser
      # Link destinations and titles, spec section 6.3. "Spaces" allow up to
      # one line ending.
      module LinkSyntax
        SPACES = /[ \t]*(?:\n[ \t]*)?/
        POINTY_DESTINATION = /<((?:[^<>\n\\]|\\.)*)>/
        DESTINATION_TEXT = /(?:[^\x00-\x20()\\\x7F]|\\.?)+/
        # cmark's limit, which also keeps unclosed destinations linear.
        MAX_PAREN_DEPTH = 32
        TITLE = /"(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*'|\((?:[^()\\]|\\.)*\)/m

        class << self
          # The attrs of `(destination "title")` right after a `]`, or nil with
          # the scanner untouched.
          def inline_link(scanner)
            start = scanner.pos
            attrs = link_attrs(scanner) if scanner.skip("(")
            scanner.pos = start unless attrs
            attrs
          end

          private

          def link_attrs(scanner)
            scanner.skip(SPACES)
            destination = scanner.match?(")") ? "" : scan_destination(scanner)
            return unless destination

            spaced = scanner.skip(SPACES).positive?
            # Without its quotes or parentheses.
            title = scanner.matched[1...-1] if spaced && scanner.skip(TITLE)
            scanner.skip(SPACES)
            return unless scanner.skip(")")

            attrs = {destination: Escapes.unescape(destination)}
            attrs[:title] = Escapes.unescape(title) if title
            attrs
          end

          def scan_destination(scanner)
            return scanner[1] if scanner.skip(POINTY_DESTINATION)
            return if scanner.match?("<")

            start = scanner.pos
            depth = 0
            loop do
              scanner.skip(DESTINATION_TEXT)
              if scanner.skip("(")
                depth += 1
                return if depth > MAX_PAREN_DEPTH
              elsif depth.positive? && scanner.skip(")")
                depth -= 1
              else
                break
              end
            end
            scanner.string.byteslice(start...scanner.pos) if depth.zero? && scanner.pos > start
          end
        end
      end
    end
  end
end
