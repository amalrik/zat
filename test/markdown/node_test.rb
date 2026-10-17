# frozen_string_literal: true

require "test_helper"
require "zat/markdown"

class MarkdownNodeTest < Minitest::Test
  Node = Zat::Markdown::Node

  def test_defaults_share_frozen_empty_attrs_and_children
    a = Node.new(type: :text, value: "a")
    b = Node.new(type: :softbreak)

    assert_same a.attrs, b.attrs
    assert_same a.children, b.children
    assert_predicate a.attrs, :frozen?
    assert_predicate a.children, :frozen?
  end

  def test_nodes_are_values
    assert_equal heading("Hi"), heading("Hi")
    refute_equal heading("Hi"), heading("Bye")
  end

  def test_pattern_matching_on_type_and_attrs
    level = case heading("Hi")
    in {type: :heading, attrs: {level:}} then level
    end

    assert_equal 2, level
  end

  def test_a_shareable_tree_crosses_into_a_ractor
    tree = Ractor.make_shareable(document(heading(+"Hi")))

    assert Ractor.shareable?(tree)
    assert_equal "Hi", Ractor.new(tree) { it.children.first.children.first.value }.value
  end

  private

  def document(*children) = Node.new(type: :document, children:, line: 1)

  def heading(text)
    Node.new(type: :heading, attrs: {level: 2}, children: [Node.new(type: :text, value: text)], line: 1)
  end
end
