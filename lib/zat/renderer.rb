# frozen_string_literal: true

require_relative "renderer/theme"

module Zat
  # Holds per-document state: build one per document, never share one.
  class Renderer
    HEADING_STYLES = {1 => :heading_1, 2 => :heading_2}.freeze
    HEADING_RULES = {1 => "━", 2 => "─"}.freeze
    QUOTE_MARK = "│ "
    GUTTER_MARK = "▏ "
    # Raw ESC, CSI and friends in the source must not reach the terminal.
    CONTROL = /[\p{Cc}&&[^\t\n]]/
    REPLACEMENT_CHARACTER = 0xFFFD.chr(Encoding::UTF_8).freeze

    def initialize(terminal:, theme: Theme::DARK)
      @depth = terminal.color_depth
      @columns = terminal.columns
      @theme = theme
    end

    def render(document, capacity: 0)
      @out = String.new(capacity:, encoding: Encoding::UTF_8)
      @styles = []
      @applied = []
      @prefixes = []
      @line_start = true
      blocks(document.children)
      @out
    end

    private

    def blocks(nodes)
      nodes.each_with_index do |node, i|
        newline if i.positive?
        block(node)
      end
    end

    # Leaf blocks end their own last line; containers leave that to their children.
    def block(node)
      case node.type
      when :paragraph then line { inlines(node) }
      when :heading then heading(node)
      when :block_quote then prefixed(:block_quote, QUOTE_MARK) { blocks(node.children) }
      when :thematic_break then line { styled(:thematic_break) { write("─" * width) } }
      when :code_block then prefixed(:code_block_gutter, GUTTER_MARK) { line { styled(:code_block) { write(node.value.chomp) } } }
      when :html_block then line { styled(:html) { write(node.value.chomp) } }
      else raise ArgumentError, "can't render #{node.type} blocks yet"
      end
    end

    def heading(node)
      level = node.attrs[:level]
      element = HEADING_STYLES.fetch(level, :heading)
      line { styled(element) { inlines(node) } }
      rule = HEADING_RULES[level] or return
      line { styled(element) { write(rule * width) } }
    end

    def inlines(node) = node.children.each { inline(it) }

    def inline(node)
      case node.type
      when :text then write(node.value)
      when :softbreak, :linebreak then newline
      when :code then styled(:code) { write(node.value) }
      when :emph, :strong, :strikethrough then styled(node.type) { inlines(node) }
      when :html_inline then styled(:html) { write(node.value) }
      # Placeholders until hyperlinks (#13) and images (#19–#21).
      when :link, :image then styled(:link) { inlines(node) }
      else raise ArgumentError, "can't render #{node.type} inlines yet"
      end
    end

    # Styles reach the output only with the text they apply to.
    def styled(element)
      @styles << @theme[element]
      yield
      @styles.pop
    end

    def line
      yield
      newline
    end

    def prefixed(element, mark)
      @prefixes << [@theme[element], mark]
      yield
      @prefixes.pop
    end

    def write(text)
      text.split("\n", -1).each_with_index do |line, i|
        newline if i.positive?
        next if line.empty?

        start_line if @line_start
        apply_styles
        @out << (CONTROL.match?(line) ? line.gsub(CONTROL, REPLACEMENT_CHARACTER) : line)
      end
    end

    def start_line
      @line_start = false
      @prefixes.each { |style, mark| @out << style.open(@depth) << mark << style.close(@depth) }
    end

    # Closing a style takes a full reset, so whatever stays open is reopened.
    def apply_styles
      return if @applied == @styles

      unless @styles.first(@applied.size) == @applied
        @out << Terminal::Style.reset(@depth) unless @applied.all?(&:plain?)
        @applied = []
      end
      @styles.drop(@applied.size).each { @out << it.open(@depth) }
      @applied = @styles.dup
    end

    # Blank lines still carry the prefixes, minus trailing spaces.
    def newline
      if @line_start
        @prefixes.each_with_index do |(style, mark), i|
          mark = mark.rstrip if i == @prefixes.size - 1
          @out << style.open(@depth) << mark << style.close(@depth)
        end
      else
        @out << Terminal::Style.reset(@depth) unless @applied.all?(&:plain?)
        @applied = []
      end
      @out << "\n"
      @line_start = true
    end

    def width = [@columns - @prefixes.sum { |_, mark| mark.length }, 1].max
  end
end
