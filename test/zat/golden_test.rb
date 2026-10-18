# frozen_string_literal: true

require "test_helper"
require "zat"
require_relative "../support/golden"

class GoldenTest < Minitest::Test
  include Golden

  Golden.names.each do |name|
    define_method(:"test_#{name}") { assert_golden(name) }
  end
end
