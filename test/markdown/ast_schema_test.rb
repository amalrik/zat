# frozen_string_literal: true

require "test_helper"
require "zat/markdown"
require_relative "support/ast_schema"

class ASTSchemaTest < Minitest::Test
  include ASTAssertions

  Node = Zat::Markdown::Node

  def test_accepts_a_valid_tree
    assert_valid_ast document(heading(text("Hi")), list(item(task: :done)))
  end

  def test_rejects_an_unknown_type
    assert_rejected(/unknown node type :para/) { document(Node.new(type: :para, line: 1)) }
  end

  def test_rejects_an_unknown_attr
    assert_rejected(/unexpected attrs on heading/) do
      document(Node.new(type: :heading, attrs: {level: 1, id: "x"}, line: 1))
    end
  end

  def test_rejects_nil_attrs
    assert_rejected(/omit optional attrs/) { document(list(item(task: nil))) }
  end

  def test_rejects_a_literal_without_value
    assert_rejected(/text needs a String value/) { document(heading(Node.new(type: :text))) }
  end

  def test_rejects_an_inline_with_a_line
    assert_rejected(/inline text takes no line/) { document(heading(Node.new(type: :text, value: "x", line: 1))) }
  end

  def test_failure_message_points_at_the_node
    assert_rejected(%r{document/heading\[0\]/text\[0\]}) { document(heading(Node.new(type: :text))) }
  end

  private

  def assert_rejected(message)
    error = assert_raises(Minitest::Assertion) { assert_valid_ast(yield) }
    assert_match message, error.message
  end

  def document(*children) = Node.new(type: :document, children:, line: 1)
  def heading(*children) = Node.new(type: :heading, attrs: {level: 1}, children:, line: 1)
  def text(value) = Node.new(type: :text, value:)
  def list(*items) = Node.new(type: :list, attrs: {ordered: false, tight: true, marker: "-"}, children: items, line: 1)
  def item(**attrs) = Node.new(type: :item, attrs:, line: 1)
end
