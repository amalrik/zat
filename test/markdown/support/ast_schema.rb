# frozen_string_literal: true

# The AST contract. Names follow the CommonMark spec. Optional attrs are
# omitted rather than nil; blocks carry a source `line`, inlines don't.
AST_SCHEMA = Ractor.make_shareable({
  document: {block: true},
  heading: {block: true, attrs: %i[level]},
  paragraph: {block: true},
  block_quote: {block: true},
  list: {block: true, attrs: %i[ordered start tight marker]},
  item: {block: true, attrs: %i[task]},
  code_block: {block: true, attrs: %i[fenced info], value: true},
  html_block: {block: true, value: true},
  thematic_break: {block: true},
  table: {block: true, attrs: %i[alignments]},
  table_row: {block: true, attrs: %i[header]},
  table_cell: {block: true},
  text: {value: true},
  softbreak: {},
  linebreak: {},
  code: {value: true},
  emph: {},
  strong: {},
  strikethrough: {},
  link: {attrs: %i[destination title autolink]},
  image: {attrs: %i[destination title]},
  html_inline: {value: true}
})

module ASTAssertions
  def assert_valid_ast(node, path = node.type.to_s)
    schema = AST_SCHEMA[node.type]
    assert schema, "#{path}: unknown node type #{node.type.inspect}"

    unknown_attrs = node.attrs.keys - schema.fetch(:attrs, [])
    assert_empty unknown_attrs, "#{path}: unexpected attrs on #{node.type}"
    refute_includes node.attrs.values, nil, "#{path}: omit optional attrs instead of setting nil"

    if schema[:value]
      assert_kind_of String, node.value, "#{path}: #{node.type} needs a String value"
    else
      assert_nil node.value, "#{path}: #{node.type} takes no value"
    end

    if schema[:block]
      assert_kind_of Integer, node.line, "#{path}: block #{node.type} needs a line"
    else
      assert_nil node.line, "#{path}: inline #{node.type} takes no line"
    end

    node.children.each_with_index { |child, i| assert_valid_ast(child, "#{path}/#{child.type}[#{i}]") }
  end
end
