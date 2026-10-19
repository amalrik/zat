# frozen_string_literal: true

require "strscan"
require_relative "entities"
require_relative "inline_parser/emphasis"

module Zat
  module Markdown
    class InlineParser
      SOFTBREAK = Node.new(type: :softbreak)
      LINEBREAK = Node.new(type: :linebreak)
      REPLACEMENT_CHARACTER = 0xFFFD.chr(Encoding::UTF_8).freeze
      MAX_CODEPOINT = 0x10FFFF
      SURROGATES = 0xD800..0xDFFF

      TEXT = /[^\\`&<\n*_~\[\]!]+/
      ESCAPABLE = /\\(?<escaped>[!-\/:-@\[-`{-~])/
      ENTITY = /&(?:#[xX](?<hex>\h{1,6})|#(?<decimal>\d{1,7})|(?<name>[A-Za-z][A-Za-z0-9]{1,31}));/
      UNESCAPE = /#{ESCAPABLE}|#{ENTITY}/
      BACKTICKS = /`+/
      DELIMITER_RUN = /\*+|_+|~+/
      PREVIOUS_CHARACTER = /(?<=(.))/m
      # Link syntax, spec section 6.3. "Spaces" allow up to one line ending.
      SPACES = /[ \t]*(?:\n[ \t]*)?/
      POINTY_DESTINATION = /<((?:[^<>\n\\]|\\.)*)>/
      DESTINATION_TEXT = /(?:[^\x00-\x20()\\\x7F]|\\.?)+/
      # cmark's limit, which also keeps unclosed destinations linear.
      MAX_PAREN_DEPTH = 32
      TITLE = /"(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*'|\((?:[^()\\]|\\.)*\)/m
      NEXT_CHARACTER = /./m
      URI_AUTOLINK = /<([A-Za-z][A-Za-z0-9+.-]{1,31}:[^\x00-\x20<>]*)>/
      EMAIL_AUTOLINK = /<([A-Za-z0-9.!#$%&'*+\/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)*)>/

      # Raw HTML, spec section 6.6. "Whitespace" allows up to one line ending.
      HTML_WHITESPACE = /(?:[ \t]*\n?[ \t]*)/
      ATTRIBUTE = /#{HTML_WHITESPACE}(?<=[ \t\n])[A-Za-z_:][A-Za-z0-9_.:-]*(?:#{HTML_WHITESPACE}=#{HTML_WHITESPACE}(?:[^ \t\n"'=<>`]+|'[^']*'|"[^"]*"))?/
      OPEN_TAG = /<[A-Za-z][A-Za-z0-9-]*#{ATTRIBUTE}*#{HTML_WHITESPACE}\/?>/
      CLOSING_TAG = /<\/[A-Za-z][A-Za-z0-9-]*#{HTML_WHITESPACE}>/
      # These end at a terminator that may never come: a failed search means
      # none exists further on either, so each is searched for at most once.
      UNTIL_TERMINATOR = Ractor.make_shareable({
        comment: [/<!--(?:-?>|.*?-->)/m, "<!--"],
        processing_instruction: [/<\?.*?\?>/m, "<?"],
        cdata: [/<!\[CDATA\[.*?\]\]>/m, "<![CDATA["],
        declaration: [/<![A-Za-z][^>]*>/, "<!"]
      })

      # Where a `[` or `![` sits in the node list, until a `]` settles it.
      Bracket = Data.define(:index, :image)

      class << self
        def parse(raw) = raw.empty? ? NO_CHILDREN : new(raw).parse

        # Backslash escapes and entities only, for info strings, destinations and titles.
        def unescape(raw)
          raw.gsub(UNESCAPE) do
            match = Regexp.last_match
            match[:escaped] || decode_entity(match) || match[0]
          end
        end

        # Takes a MatchData or a StringScanner positioned on ENTITY. nil for an
        # unknown name, which then stays as literal text.
        def decode_entity(match)
          return ENTITIES[match[:name]] if match[:name]

          codepoint = match[:hex] ? match[:hex].to_i(16) : match[:decimal].to_i
          valid = codepoint.positive? && codepoint <= MAX_CODEPOINT && !SURROGATES.cover?(codepoint)
          valid ? codepoint.chr(Encoding::UTF_8) : REPLACEMENT_CHARACTER
        end
      end

      def initialize(raw)
        # Fixed anchor lets lookbehind see the text before the scan position.
        @scanner = StringScanner.new(raw, fixed_anchor: true)
        @nodes = []
        @text = +""
        @unterminated = []
        @brackets = []
        # Links can't contain links: once one closes, every `[` still open
        # below this height is dead.
        @dead_below = 0
        # Set up front so every parser has the same shape.
        @last_backtick_run = nil
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
        Emphasis.process(@nodes)
      end

      private

      def special
        case @scanner.peek(1)
        when "\\" then backslash
        when "`" then code_span
        when "&" then entity
        when "<" then angle_bracket
        when "\n" then line_ending
        when "*", "_", "~" then delimiter_run
        when "[" then open_bracket
        when "!" then @scanner.match?("![") ? open_bracket : @text << @scanner.getch
        when "]" then close_bracket
        else raise ArgumentError, "TEXT stopped at #{@scanner.peek(1).inspect}, which has no handler"
        end
      end

      def backslash
        if @scanner.skip(ESCAPABLE)
          @text << @scanner[:escaped]
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
        if closer_ahead?(opener) && (content = @scanner.scan_until(/(?<!`)#{opener}(?!`)/))
          add(Node.new(type: :code, value: code_content(content.delete_suffix(opener))))
        else
          @text << opener
        end
      end

      def closer_ahead?(opener)
        last = last_backtick_run[opener.size]
        !last.nil? && last >= @scanner.pos
      end

      def last_backtick_run
        @last_backtick_run ||= begin
          runs = {}
          @scanner.string.scan(BACKTICKS) { runs[it.size] = Regexp.last_match.byteoffset(0).first }
          runs
        end
      end

      def code_content(content)
        content = content.tr("\n", " ")
        stripped = content.start_with?(" ") && content.end_with?(" ") && !content.match?(/\A +\z/)
        stripped ? content[1..-2] : content
      end

      def delimiter_run
        before = @scanner[1] if @scanner.check(PREVIOUS_CHARACTER)
        run = @scanner.scan(DELIMITER_RUN)
        delimiter = Emphasis::Delimiter.for(run, before, @scanner.check(NEXT_CHARACTER))
        if delimiter.can_open || delimiter.can_close
          add(delimiter)
        else
          @text << run
        end
      end

      def open_bracket
        flush
        bracket = @scanner.scan(/!?\[/)
        @brackets << Bracket.new(index: @nodes.size, image: bracket.start_with?("!"))
        @nodes << Node.new(type: :text, value: bracket)
      end

      def close_bracket
        @scanner.skip("]")
        bracket = pop_bracket
        attrs = inline_link if bracket
        if attrs
          add_link(bracket, attrs)
        else
          @text << "]"
        end
      end

      # The innermost `[` or `![`, unless there is none or it can no longer open a link.
      def pop_bracket
        return if @brackets.empty?

        dead = @brackets.size <= @dead_below
        bracket = @brackets.pop
        @dead_below = [@dead_below, @brackets.size].min
        bracket if bracket.image || !dead
      end

      def add_link(bracket, attrs)
        flush
        children = Emphasis.process(@nodes.slice!(bracket.index + 1..))
        @nodes.pop # the bracket's own text
        @nodes << Node.new(type: bracket.image ? :image : :link, attrs:, children:)
        @dead_below = @brackets.size unless bracket.image
      end

      # `(destination "title")` right after the `]`, or nil with the scanner untouched.
      def inline_link
        start = @scanner.pos
        attrs = link_attrs if @scanner.skip("(")
        @scanner.pos = start unless attrs
        attrs
      end

      def link_attrs
        @scanner.skip(SPACES)
        destination = @scanner.match?(")") ? "" : link_destination
        return unless destination

        spaced = @scanner.skip(SPACES).positive?
        # Without its quotes or parentheses.
        title = @scanner.matched[1...-1] if spaced && @scanner.skip(TITLE)
        @scanner.skip(SPACES)
        return unless @scanner.skip(")")

        attrs = {destination: self.class.unescape(destination)}
        attrs[:title] = self.class.unescape(title) if title
        attrs
      end

      def link_destination
        return @scanner[1] if @scanner.skip(POINTY_DESTINATION)
        return if @scanner.match?("<")

        start = @scanner.pos
        depth = 0
        loop do
          @scanner.skip(DESTINATION_TEXT)
          if @scanner.skip("(")
            depth += 1
            return if depth > MAX_PAREN_DEPTH
          elsif depth.positive? && @scanner.skip(")")
            depth -= 1
          else
            break
          end
        end
        @scanner.string.byteslice(start...@scanner.pos) if depth.zero? && @scanner.pos > start
      end

      def entity
        if @scanner.check(ENTITY) && (decoded = self.class.decode_entity(@scanner))
          @scanner.pos += @scanner.matched_size
          @text << decoded
        else
          @text << @scanner.getch
        end
      end

      def angle_bracket
        if @scanner.skip(URI_AUTOLINK)
          autolink(@scanner[1], @scanner[1])
        elsif @scanner.skip(EMAIL_AUTOLINK)
          autolink("mailto:#{@scanner[1]}", @scanner[1])
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
        kind, (pattern, _) = UNTIL_TERMINATOR.find { |_, (_, start)| @scanner.match?(start) }
        return if kind.nil? || @unterminated.include?(kind)

        @scanner.scan(pattern).tap { @unterminated << kind unless it }
      end

      # Two or more trailing spaces make a hard break; any trailing spaces go.
      def line_ending
        @scanner.skip("\n")
        trailing = @text.slice!(/ +\z/).to_s.size
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
