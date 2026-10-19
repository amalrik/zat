# frozen_string_literal: true

require "strscan"
require_relative "entities"

module Zat
  module Markdown
    # Scans the text and dispatches on the characters that may start a
    # construct. Handlers consume at least one character and return either a
    # Node or the text they read; emphasis and links, which wrap nodes already
    # emitted, are settled here.
    class InlineParser
      SOFTBREAK = Node.new(type: :softbreak)
      LINEBREAK = Node.new(type: :linebreak)
      TEXT = /[^\\`&<\n*_~\[\]!]+/
      DELIMITER_RUN = /\*+|_+|~+/
      PREVIOUS_CHARACTER = /(?<=(.))/m
      NEXT_CHARACTER = /./m
      BRACKET = /!?\[/

      def self.parse(raw) = raw.empty? ? NO_CHILDREN : new(raw).parse

      def initialize(raw)
        # Fixed anchor lets lookbehind see the text before the scan position.
        @scanner = StringScanner.new(raw, fixed_anchor: true)
        @nodes = []
        @text = +""
        @code_spans = CodeSpans.new(@scanner)
        @raw_html = RawHTML.new(@scanner)
        @brackets = Brackets.new
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
        when "`" then emit(@code_spans.scan)
        when "&" then @text << Escapes.entity(@scanner)
        when "<" then emit(Autolinks.scan(@scanner) || @raw_html.scan || @scanner.getch)
        when "\n" then line_ending
        when "*", "_", "~" then delimiter_run
        when "[" then open_bracket
        when "!" then @scanner.match?("![") ? open_bracket : @text << @scanner.getch
        when "]" then close_bracket
        else raise ArgumentError, "TEXT stopped at #{@scanner.peek(1).inspect}, which has no handler"
        end
      end

      def emit(result) = result.is_a?(Node) ? add(result) : @text << result

      def backslash
        if @scanner.skip(Escapes::ESCAPABLE)
          @text << @scanner[:escaped]
        elsif @scanner.skip("\\\n")
          line_break(LINEBREAK)
        else
          @text << @scanner.getch
        end
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
        bracket = @scanner.scan(BRACKET)
        @brackets.push(index: @nodes.size, image: bracket.start_with?("!"))
        @nodes << Node.new(type: :text, value: bracket)
      end

      def close_bracket
        @scanner.skip("]")
        opener = @brackets.pop
        attrs = LinkSyntax.inline_link(@scanner) if opener
        if attrs
          add_link(opener, attrs)
        else
          @text << "]"
        end
      end

      def add_link(opener, attrs)
        flush
        children = Emphasis.process(@nodes.slice!(opener.index + 1..))
        @nodes.pop # the opener's own text
        @nodes << Node.new(type: opener.image ? :image : :link, attrs:, children:)
        @brackets.link_closed unless opener.image
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

require_relative "inline_parser/escapes"
require_relative "inline_parser/code_spans"
require_relative "inline_parser/autolinks"
require_relative "inline_parser/raw_html"
require_relative "inline_parser/link_syntax"
require_relative "inline_parser/brackets"
require_relative "inline_parser/emphasis"
