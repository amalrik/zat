# frozen_string_literal: true

# Renders a Zat::Markdown AST as HTML byte-compatible with cmark/cmark-gfm,
# whose output the spec examples were generated with. Test-only: Zat never
# renders HTML itself.
class SpecHTML
  ESCAPES = {"&" => "&amp;", "<" => "&lt;", ">" => "&gt;", '"' => "&quot;"}.freeze
  # cmark leaves these as-is in URLs and percent-encodes everything else.
  HREF_SAFE = /[A-Za-z0-9\-_.+!*'(),%#@?=;:\/$~&\[\]]/

  def self.render(node) = new.render(node)

  def render(node)
    @out = +""
    block(node, tight: false)
    @out
  end

  private

  def block(node, tight:)
    case node.type
    when :document then node.children.each { block(it, tight:) }
    when :paragraph
      if tight
        inlines(node)
      else
        cr
        tag("p") { inlines(node) }
        @out << "\n"
      end
    when :heading
      cr
      tag("h#{node.attrs[:level]}") { inlines(node) }
      @out << "\n"
    when :thematic_break
      cr
      @out << "<hr />\n"
    when :block_quote then wrap("blockquote") { node.children.each { block(it, tight: false) } }
    when :list then list(node)
    when :item then item(node, tight:)
    when :code_block then code_block(node)
    when :html_block
      cr
      @out << node.value
      cr
    when :table then table(node)
    else raise ArgumentError, "not a block: #{node.type}"
    end
  end

  def list(node)
    attrs = node.attrs
    name = attrs[:ordered] ? "ol" : "ul"
    start = (attrs[:ordered] && attrs[:start] != 1) ? %( start="#{attrs[:start]}") : ""
    cr
    @out << "<#{name}#{start}>\n"
    node.children.each { block(it, tight: attrs[:tight]) }
    cr
    @out << "</#{name}>\n"
  end

  def item(node, tight:)
    cr
    @out << "<li>"
    case node.attrs[:task]
    when :open then @out << %(<input disabled="" type="checkbox"> )
    when :done then @out << %(<input checked="" disabled="" type="checkbox"> )
    end
    node.children.each { block(it, tight:) }
    @out << "</li>\n"
  end

  def code_block(node)
    cr
    language = node.attrs[:info]&.split&.first
    @out << (language ? %(<pre><code class="language-#{escape(language)}">) : "<pre><code>")
    @out << escape(node.value) << "</code></pre>\n"
  end

  def table(node)
    alignments = node.attrs[:alignments]
    header, *body = node.children
    cr
    @out << "<table>\n<thead>\n"
    row(header, "th", alignments)
    @out << "</thead>\n"
    unless body.empty?
      @out << "<tbody>\n"
      body.each { row(it, "td", alignments) }
      @out << "</tbody>\n"
    end
    @out << "</table>\n"
  end

  def row(node, cell, alignments)
    @out << "<tr>\n"
    node.children.each_with_index do |child, i|
      align = alignments[i] ? %( align="#{alignments[i]}") : ""
      @out << "<#{cell}#{align}>"
      inlines(child)
      @out << "</#{cell}>\n"
    end
    @out << "</tr>\n"
  end

  def inlines(node) = node.children.each { inline(it) }

  def inline(node)
    case node.type
    when :text then @out << escape(node.value)
    when :softbreak then @out << "\n"
    when :linebreak then @out << "<br />\n"
    when :code then @out << "<code>" << escape(node.value) << "</code>"
    when :emph then tag("em") { inlines(node) }
    when :strong then tag("strong") { inlines(node) }
    when :strikethrough then tag("del") { inlines(node) }
    when :html_inline then @out << node.value
    when :link
      @out << %(<a href="#{href(node.attrs[:destination])}") << title(node) << ">"
      inlines(node)
      @out << "</a>"
    when :image
      @out << %(<img src="#{href(node.attrs[:destination])}" alt="#{escape(plain_text(node))}") << title(node) << " />"
    else raise ArgumentError, "not an inline: #{node.type}"
    end
  end

  def plain_text(node)
    node.children.sum("") do |child|
      case child.type
      when :text, :code, :html_inline then child.value
      when :softbreak, :linebreak then "\n"
      else plain_text(child)
      end
    end
  end

  def title(node) = node.attrs[:title] ? %( title="#{escape(node.attrs[:title])}") : ""

  def href(url)
    url.each_char.sum("") { |char| HREF_SAFE.match?(char) ? char : char.bytes.sum("") { |byte| format("%%%02X", byte) } }
      .gsub("&", "&amp;")
  end

  def tag(name)
    @out << "<#{name}>"
    yield
    @out << "</#{name}>"
  end

  def wrap(name)
    cr
    @out << "<#{name}>\n"
    yield
    cr
    @out << "</#{name}>\n"
  end

  def cr = (@out << "\n" unless @out.empty? || @out.end_with?("\n"))

  def escape(text) = text.gsub(/[&<>"]/, ESCAPES)
end
