# frozen_string_literal: true

require "test_helper"
require "open3"

# Zat::Markdown is meant to become its own gem, so it must load without the
# rest of Zat. Checked in a fresh process because `rake test` loads everything.
class MarkdownBoundaryTest < Minitest::Test
  LIB = File.expand_path("../../lib", __dir__)

  def test_loads_without_the_rest_of_zat
    script = 'require "zat/markdown"; print Zat.constants.sort.inspect'
    out, err, status = unbundled { Open3.capture3(RbConfig.ruby, "-I", LIB, "-e", script) }

    assert_predicate status, :success?, err
    assert_equal "[:Markdown]", out, "zat/markdown loaded other parts of Zat"
  end

  private

  # Under `bundle exec`, Bundler evaluates zat.gemspec in every child process,
  # which loads zat/version. Restoring the pre-Bundler environment avoids that
  # and keeps the caller's own RUBYOPT (e.g. --zjit).
  def unbundled(&) = defined?(Bundler) ? Bundler.with_unbundled_env(&) : yield
end
