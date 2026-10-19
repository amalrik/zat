# frozen_string_literal: true

module Zat
  module Markdown
    class InlineParser
      # Spec section 6.6. "Whitespace" allows up to one line ending.
      class RawHTML
        WHITESPACE = /(?:[ \t]*\n?[ \t]*)/
        ATTRIBUTE = /#{WHITESPACE}(?<=[ \t\n])[A-Za-z_:][A-Za-z0-9_.:-]*(?:#{WHITESPACE}=#{WHITESPACE}(?:[^ \t\n"'=<>`]+|'[^']*'|"[^"]*"))?/
        OPEN_TAG = /<[A-Za-z][A-Za-z0-9-]*#{ATTRIBUTE}*#{WHITESPACE}\/?>/
        CLOSING_TAG = /<\/[A-Za-z][A-Za-z0-9-]*#{WHITESPACE}>/
        # These end at a terminator that may never come: a failed search means
        # none exists further on either, so each is searched for at most once.
        UNTIL_TERMINATOR = Ractor.make_shareable({
          comment: [/<!--(?:-?>|.*?-->)/m, "<!--"],
          processing_instruction: [/<\?.*?\?>/m, "<?"],
          cdata: [/<!\[CDATA\[.*?\]\]>/m, "<![CDATA["],
          declaration: [/<![A-Za-z][^>]*>/, "<!"]
        })

        def initialize(scanner)
          @scanner = scanner
          @unterminated = []
        end

        # An :html_inline node, or nil with the scanner untouched.
        def scan
          html = @scanner.scan(OPEN_TAG) || @scanner.scan(CLOSING_TAG) || until_terminator
          Node.new(type: :html_inline, value: html) if html
        end

        private

        def until_terminator
          kind, (pattern, _) = UNTIL_TERMINATOR.find { |_, (_, start)| @scanner.match?(start) }
          return if kind.nil? || @unterminated.include?(kind)

          @scanner.scan(pattern).tap { @unterminated << kind unless it }
        end
      end
    end
  end
end
