# frozen_string_literal: true

module Zat
  module Markdown
    class BlockParser
      BLANK = /\A[ \t]*\z/
      THEMATIC_BREAK = /\A {0,3}(?:(?:\*[ \t]*){3,}|(?:-[ \t]*){3,}|(?:_[ \t]*){3,})\z/
      ATX_HEADING = /\A {0,3}(\#{1,6})(?=[ \t]|\z)(.*)\z/
      ATX_CLOSING_SEQUENCE = /(?:\A|[ \t]+)\#+[ \t]*\z/
      SETEXT_UNDERLINE = /\A {0,3}(=+|-+)[ \t]*\z/

      def self.parse(source) = new.parse(source)

      def parse(source)
        @blocks = []
        @paragraph = nil
        normalize(source).each_line(chomp: true).with_index(1) { |line, number| add_line(line, number) }
        close_paragraph
        Node.new(type: :document, children: @blocks, line: 1)
      end

      private

      def normalize(source) = source.gsub(/\r\n?|\0/, "\r\n" => "\n", "\r" => "\n", "\0" => "�")

      def add_line(line, number)
        if BLANK.match?(line)
          close_paragraph
        elsif @paragraph && (underline = SETEXT_UNDERLINE.match(line))
          close_paragraph(heading_level: underline[1].start_with?("=") ? 1 : 2)
        elsif THEMATIC_BREAK.match?(line)
          close_paragraph
          @blocks << Node.new(type: :thematic_break, line: number)
        elsif (heading = ATX_HEADING.match(line))
          close_paragraph
          add_atx_heading(heading, number)
        elsif @paragraph
          @paragraph[:lines] << strip_leading(line)
        else
          @paragraph = {line: number, lines: [strip_leading(line)]}
        end
      end

      def add_atx_heading(match, number)
        content = strip(match[2].sub(ATX_CLOSING_SEQUENCE, ""))
        @blocks << Node.new(type: :heading, attrs: {level: match[1].size}, children: InlineParser.parse(content), line: number)
      end

      def close_paragraph(heading_level: nil)
        return unless @paragraph

        content = strip(@paragraph[:lines].join("\n"))
        @blocks << if heading_level
          Node.new(type: :heading, attrs: {level: heading_level}, children: InlineParser.parse(content), line: @paragraph[:line])
        else
          Node.new(type: :paragraph, children: InlineParser.parse(content), line: @paragraph[:line])
        end
        @paragraph = nil
      end

      def strip_leading(line) = line.sub(/\A[ \t]+/, "")

      def strip(text) = text.gsub(/\A[ \t]+|[ \t]+\z/, "")
    end
  end
end
