# frozen_string_literal: true

require "test_helper"
require "open3"

# Needs a fresh process: `rake test` has already loaded all of Zat.
class MarkdownBoundaryTest < Minitest::Test
  LIB = File.expand_path("../../lib", __dir__)

  def test_loads_without_the_rest_of_zat
    script = 'require "zat/markdown"; print Zat.constants.sort.inspect'
    out, err, status = unbundled { Open3.capture3(RbConfig.ruby, "-I", LIB, "-e", script) }

    assert_predicate status, :success?, err
    assert_equal "[:Markdown]", out, "zat/markdown loaded other parts of Zat"
  end

  private

  # Under `bundle exec`, Bundler evaluates zat.gemspec in child processes, which
  # loads zat/version. The unbundled env avoids that and keeps RUBYOPT's --zjit.
  def unbundled(&) = defined?(Bundler) ? Bundler.with_unbundled_env(&) : yield
end
