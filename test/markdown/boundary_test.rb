# frozen_string_literal: true

require "test_helper"
require "open3"

# Zat::Markdown is meant to become its own gem, so it must load without the
# rest of Zat. Checked in a fresh process because `rake test` loads everything.
class MarkdownBoundaryTest < Minitest::Test
  LIB = File.expand_path("../../lib", __dir__)

  def test_loads_without_the_rest_of_zat
    script = 'require "zat/markdown"; print Zat.constants.sort.inspect'
    out, err, status = Open3.capture3(env_without_bundler, RbConfig.ruby, "-I", LIB, "-e", script)

    assert_predicate status, :success?, err
    assert_equal "[:Markdown]", out
  end

  private

  # `bundle exec` puts -rbundler/setup in RUBYOPT, and Bundler evaluates
  # zat.gemspec, which loads zat/version. Drop it but keep any JIT flags.
  def env_without_bundler
    rubyopt = ENV.fetch("RUBYOPT", "").split.reject { it.start_with?("-r") && it.end_with?("bundler/setup") }
    { "RUBYOPT" => rubyopt.join(" ") }
  end
end
