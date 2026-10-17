# frozen_string_literal: true

require "test_helper"
require "zat/markdown"
require_relative "support/ast_schema"
require_relative "support/spec_suite"

# Ratchet over the CommonMark and GFM spec examples: those listed in
# spec/passing.txt must pass, and any other example that starts passing must
# be added to the list (`rake spec:update`), so every PR shows its progress.
class SpecTest < Minitest::Test
  include ASTAssertions

  PASSING = SpecSuite.passing_ids.to_set.freeze

  SpecSuite.examples.select { PASSING.include?(it.id) }.each do |example|
    define_method(:"test_#{example.spec}_#{example.number}") do
      assert_equal example.html, SpecSuite.render(example), "#{example}\n\n#{example.markdown}"
    end
  end

  def test_passing_list_has_no_unknown_examples
    assert_empty PASSING - SpecSuite.examples.map(&:id)
  end

  def test_no_example_passes_without_being_listed
    newly_passing = SpecSuite.examples.reject { PASSING.include?(it.id) }.select { SpecSuite.passes?(it) }

    assert_empty newly_passing.map(&:to_s), "Newly passing examples: run `rake spec:update`"
  end

  def test_every_example_parses_to_a_valid_ast
    SpecSuite.examples.each { assert_valid_ast(Zat::Markdown.parse(it.markdown)) }
  end
end
