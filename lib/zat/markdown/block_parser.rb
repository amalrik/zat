# frozen_string_literal: true

module Zat
  module Markdown
    class BlockParser
      BLANK = /\A[ \t]*\z/
      THEMATIC_BREAK = /\A {0,3}(?:(?:\*[ \t]*){3,}|(?:-[ \t]*){3,}|(?:_[ \t]*){3,})\z/
      ATX_HEADING = /\A {0,3}(\#{1,6})(?=[ \t]|\z)(.*)\z/
      ATX_CLOSING_SEQUENCE = /(?:\A|[ \t]+)#+[ \t]*\z/
      SETEXT_UNDERLINE = /\A {0,3}(=+|-+)[ \t]*\z/
      FENCE_OPENING = /\A( {0,3})(`{3,}|~{3,})(.*)\z/
      FENCE_CLOSING = /\A {0,3}(`{3,}|~{3,})[ \t]*\z/
      CODE_INDENT = 4
      TAB_STOP = 4
      REPLACEMENT_CHARACTER = 0xFFFD.chr(Encoding::UTF_8).freeze

      Paragraph = Struct.new(:line, :lines)
      IndentedCode = Struct.new(:line, :lines)
      Fence = Struct.new(:line, :indent, :marker, :info, :lines)
      private_constant :Paragraph, :IndentedCode, :Fence

      def self.parse(source) = new(source).parse

      def initialize(source)
        @source = source
        @blocks = []
        @paragraph = nil
        @indented_code = nil
        @fence = nil
      end

      def parse
        normalized_source.each_line(chomp: true).with_index(1) { |line, number| add_line(line, number) }
        close_paragraph
        close_indented_code
        close_fence
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
        if @fence
          continue_fence(line)
        elsif continues_indented_code?(line)
          @indented_code.lines << remove_indentation(line, CODE_INDENT)
        else
          close_indented_code
          start_block(line, number)
        end
      end

      def start_block(line, number)
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
        elsif (fence = fence_opening(line, number))
          close_paragraph
          @fence = fence
        elsif @paragraph
          @paragraph.lines << strip_leading(line)
        elsif indentation(line) >= CODE_INDENT
          @indented_code = IndentedCode.new(number, [remove_indentation(line, CODE_INDENT)])
        else
          @paragraph = Paragraph.new(number, [strip_leading(line)])
        end
      end

      def fence_opening(line, number)
        match = FENCE_OPENING.match(line) or return
        indent, marker, info = match.captures
        return if marker.start_with?("`") && info.include?("`")

        Fence.new(number, indent.size, marker, InlineParser.unescape(strip(info)), [])
      end

      def continue_fence(line)
        if closes_fence?(line)
          close_fence
        else
          @fence.lines << remove_indentation(line, @fence.indent)
        end
      end

      def closes_fence?(line)
        marker = line[FENCE_CLOSING, 1] or return false
        marker[0] == @fence.marker[0] && marker.size >= @fence.marker.size
      end

      def continues_indented_code?(line)
        @indented_code && (BLANK.match?(line) || indentation(line) >= CODE_INDENT)
      end

      def close_fence
        return unless @fence

        attrs = @fence.info.empty? ? {fenced: true} : {fenced: true, info: @fence.info}
        @blocks << Node.new(type: :code_block, value: code(@fence.lines), attrs:, line: @fence.line)
        @fence = nil
      end

      def close_indented_code
        return unless @indented_code

        lines = @indented_code.lines
        lines.pop while BLANK.match?(lines.last)
        @blocks << Node.new(type: :code_block, value: code(lines), attrs: {fenced: false}, line: @indented_code.line)
        @indented_code = nil
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

      def code(lines) = lines.map { "#{it}\n" }.join

      def paragraph_content = strip(@paragraph.lines.join("\n"))

      def indentation(line)
        line.each_char.reduce(0) do |column, char|
          case char
          when " " then column + 1
          when "\t" then column + TAB_STOP - (column % TAB_STOP)
          else break column
          end
        end
      end

      # Removes up to `columns` columns of leading whitespace. A tab that is
      # only partly consumed leaves the rest of its width as spaces.
      def remove_indentation(line, columns)
        column = 0
        line.each_char.with_index do |char, i|
          return line[i..] if column >= columns

          width = case char
          when " " then 1
          when "\t" then TAB_STOP - (column % TAB_STOP)
          else return line[i..]
          end
          return " " * (column + width - columns) + line[(i + 1)..] if column + width > columns

          column += width
        end
        ""
      end

      # Not String#strip: it also removes \f, \v and \0, which the spec treats as content.
      def strip(text) = text.gsub(/\A[ \t]+|[ \t]+\z/, "")

      def strip_leading(line) = line.sub(/\A[ \t]+/, "")
    end
  end
end
