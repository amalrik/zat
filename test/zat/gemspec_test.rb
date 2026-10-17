# frozen_string_literal: true

require "test_helper"

class GemspecTest < Minitest::Test
  def setup
    @spec = Gem::Specification.load(File.expand_path("../../zat.gemspec", __dir__))
  end

  def test_has_no_runtime_dependencies
    assert_empty @spec.runtime_dependencies.map(&:name)
  end

  def test_ships_the_executable
    assert_equal ["zat"], @spec.executables
    assert_includes @spec.files, "exe/zat"
  end
end
