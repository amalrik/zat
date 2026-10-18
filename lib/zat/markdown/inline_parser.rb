# frozen_string_literal: true

require "strscan"
require_relative "entities"

module Zat
  module Markdown
    class InlineParser
      SOFTBREAK = Node.new(type: :softbreak)
      LINEBREAK = Node.new(type: :linebreak)
      REPLACEMENT_CHARACTER = 0xFFFD.chr(Encoding::UTF_8).freeze

      TEXT = /[^\\`&<\n]+/
      ESCAPABLE = /\\([!-\/:-@\[-`{-~])/
      ENTITY = /&(?:#[xX](\h{1,6})|#(\d{1,7})|([A-Za-z][A-Za-z0-9]{1,31}));/
      UNESCAPE = /#{ESCAPABLE}|#{ENTITY}/
      BACKTICKS = /`+/
      URI_AUTOLINK = /<([A-Za-z][A-Za-z0-9+.-]{1,31}:[^\x00-\x20<>]*)>/
      EMAIL_AUTOLINK = /<([A-Za-z0-9.!#$%&'*+\/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)*)>/

      # Raw HTML, spec section 6.6. "Whitespace" allows up to one line ending.
      SPACE = /(?:[ \t]*\n?[ \t]*)/
      ATTRIBUTE = /#{SPACE}(?<=[ \t\n])[A-Za-z_:][A-Za-z0-9_.:-]*(?:#{SPACE}=#{SPACE}(?:[^ \t\n"'=<>`]+|'[^']*'|"[^"]*"))?/
      OPEN_TAG = /<[A-Za-z][A-Za-z0-9-]*#{ATTRIBUTE}*#{SPACE}\/?>/
      CLOSING_TAG = /<\/[A-Za-z][A-Za-z0-9-]*#{SPACE}>/
      # These end at a terminator that may never come: a failed search means
      # none exists further on either, so each is searched for at most once.
      UNTIL_TERMINATOR = Ractor.make_shareable({
        comment: [/<!--(?:-?>|.*?-->)/m, "<!--"],
        processing_instruction: [/<\?.*?\?>/m, "<?"],
        cdata: [/<!\[CDATA\[.*?\]\]>/m, "<![CDATA["],
        declaration: [/<![A-Za-z][^>]*>/, "<!"]
      })

      class << self
        def parse(raw) = raw.empty? ? NO_CHILDREN : new(raw).parse

        # Backslash escapes and entities only, for info strings, destinations and titles.
        def unescape(raw)
          raw.gsub(UNESCAPE) { $1 || decode_entity($2, $3, $4) || $& }
        end

        def decode_entity(hex, decimal, name)
          return ENTITIES[name] if name

          codepoint = hex ? hex.to_i(16) : decimal.to_i
          valid = codepoint.positive? && codepoint <= 0x10FFFF && !(0xD800..0xDFFF).cover?(codepoint)
          valid ? codepoint.chr(Encoding::UTF_8) : REPLACEMENT_CHARACTER
        end
      end

      def initialize(raw)
        @scanner = StringScanner.new(raw)
        @nodes = []
        @text = +""
        @unterminated = []
      end

      def parse
        until @scanner.eos?
          if (text = @scanner.scan(TEXT))
            @text << text
          else
            special
          end
        end
        flush
        @nodes
      end

      private

      def special
        case @scanner.peek(1)
        when "\\" then backslash
        when "`" then code_span
        when "&" then entity
        when "<" then angle_bracket
        when "\n" then line_ending
        end
      end

      def backslash
        if (escaped = @scanner.scan(ESCAPABLE))
          @text << escaped[1]
        elsif @scanner.skip("\\\n")
          line_break(LINEBREAK)
        else
          @text << @scanner.getch
        end
      end

      # The closer is the next run of exactly as many backticks. Every run's
      # last position is known up front, so a missing closer costs nothing.
      def code_span
        opener = @scanner.scan(BACKTICKS)
        closer = /(?<!`)#{opener}(?!`)/
        if last_backtick_run.fetch(opener.size, -1) >= @scanner.pos && (content = @scanner.scan_until(closer))
          add(Node.new(type: :code, value: code_content(content.delete_suffix(opener))))
        else
          @text << opener
        end
      end

      def last_backtick_run
        @last_backtick_run ||= {}.tap do |runs|
          @scanner.string.scan(BACKTICKS) { runs[$&.size] = $~.byteoffset(0).first }
        end
      end

      def code_content(content)
        content = content.tr("\n", " ")
        stripped = content.start_with?(" ") && content.end_with?(" ") && !content.match?(/\A +\z/)
        stripped ? content[1..-2] : content
      end

      def entity
        if @scanner.check(ENTITY) && (decoded = self.class.decode_entity(@scanner[1], @scanner[2], @scanner[3]))
          @scanner.pos += @scanner.matched_size
          @text << decoded
        else
          @text << @scanner.getch
        end
      end

      def angle_bracket
        if (uri = @scanner.scan(URI_AUTOLINK))
          autolink(uri[1..-2], uri[1..-2])
        elsif (email = @scanner.scan(EMAIL_AUTOLINK))
          autolink("mailto:#{email[1..-2]}", email[1..-2])
        elsif (html = raw_html)
          add(Node.new(type: :html_inline, value: html))
        else
          @text << @scanner.getch
        end
      end

      def autolink(destination, label)
        add(Node.new(type: :link, attrs: {destination:, autolink: true}, children: [Node.new(type: :text, value: label)]))
      end

      def raw_html
        @scanner.scan(OPEN_TAG) || @scanner.scan(CLOSING_TAG) || until_terminator
      end

      def until_terminator
        UNTIL_TERMINATOR.each do |kind, (pattern, start)|
          next unless @scanner.peek(start.size) == start

          return nil if @unterminated.include?(kind)

          html = @scanner.scan(pattern)
          @unterminated << kind unless html
          return html
        end
        nil
      end

      # Two or more trailing spaces make a hard break; any trailing spaces go.
      def line_ending
        @scanner.skip(/\n/)
        trailing = @text[/ *\z/].size
        @text.slice!(-trailing..) if trailing.positive?
        line_break((trailing >= 2) ? LINEBREAK : SOFTBREAK)
      end

      def line_break(node)
        @scanner.skip(/[ \t]*/)
        add(node)
      end

      def add(node)
        flush
        @nodes << node
      end

      def flush
        return if @text.empty?

        @nodes << Node.new(type: :text, value: @text)
        @text = +""
      end
    end
  end
end
