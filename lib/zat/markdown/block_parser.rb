# frozen_string_literal: true

module Zat
  module Markdown
    class BlockParser
      BLANK = /\A[ \t]*\z/
      THEMATIC_BREAK = /\A {0,3}(?:(?:\*[ \t]*){3,}|(?:-[ \t]*){3,}|(?:_[ \t]*){3,})\z/
      ATX_HEADING = /\A {0,3}(\#{1,6})(?=[ \t]|\z)(.*)\z/
      ATX_CLOSING_SEQUENCE = /(?:\A|[ \t]+)#+[ \t]*\z/
      SETEXT_UNDERLINE = /\A {0,3}(=+|-+)[ \t]*\z/
      REPLACEMENT_CHARACTER = 0xFFFD.chr(Encoding::UTF_8).freeze

      Paragraph = Struct.new(:line, :lines)
      private_constant :Paragraph

      def self.parse(source) = new(source).parse

      def initialize(source)
        @source = source
        @blocks = []
        @paragraph = nil
      end

      def parse
        normalized_source.each_line(chomp: true).with_index(1) { |line, number| add_line(line, number) }
        close_paragraph
        Node.new(type: :document, children: @blocks, line: 1)
      end

      private

      # Other encodings are transcoded, binary is read as UTF-8, and bytes that
      # aren't valid UTF-8 become U+FFFD, as the spec does for NUL.
      def normalized_source
        utf8 = if @source.encoding == Encoding::BINARY
          String.new(@source, encoding: Encoding::UTF_8)
        else
          @source.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: REPLACEMENT_CHARACTER)
        end
        utf8.scrub(REPLACEMENT_CHARACTER).gsub(/\r\n?|\0/, "\r\n" => "\n", "\r" => "\n", "\0" => REPLACEMENT_CHARACTER)
      end

      def add_line(line, number)
        if BLANK.match?(line)
          close_paragraph
        # Checked before thematic breaks: under a paragraph, `---` is an underline.
        elsif @paragraph && (underline = SETEXT_UNDERLINE.match(line))
          add_setext_heading(underline[1].start_with?("=") ? 1 : 2)
        elsif THEMATIC_BREAK.match?(line)
          close_paragraph
          @blocks << Node.new(type: :thematic_break, line: number)
        elsif (match = ATX_HEADING.match(line))
          close_paragraph
          @blocks << heading(match[1].size, match[2].sub(ATX_CLOSING_SEQUENCE, ""), number)
        elsif @paragraph
          @paragraph.lines << strip_leading(line)
        else
          @paragraph = Paragraph.new(number, [strip_leading(line)])
        end
      end

      def add_setext_heading(level)
        @blocks << heading(level, paragraph_content, @paragraph.line)
        @paragraph = nil
      end

      def close_paragraph
        return unless @paragraph

        @blocks << Node.new(type: :paragraph, children: InlineParser.parse(paragraph_content), line: @paragraph.line)
        @paragraph = nil
      end

      def heading(level, content, line)
        Node.new(type: :heading, attrs: {level:}, children: InlineParser.parse(strip(content)), line:)
      end

      def paragraph_content = strip(@paragraph.lines.join("\n"))

      # Not String#strip: it also removes \f, \v and \0, which the spec treats as content.
      def strip(text) = text.gsub(/\A[ \t]+|[ \t]+\z/, "")

      def strip_leading(line) = line.sub(/\A[ \t]+/, "")
    end
  end
end
