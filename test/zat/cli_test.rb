# frozen_string_literal: true

require "test_helper"
require "open3"
require "zat"

class CLITest < Minitest::Test
  EXE = File.expand_path("../../exe/zat", __dir__)
  LIB = File.expand_path("../../lib", __dir__)

  def test_version
    out, err, status = zat("--version")

    assert_equal "zat #{Zat::VERSION}\n", out
    assert_empty err
    assert_predicate status, :success?
  end

  def test_help
    out, _, status = zat("--help")

    assert_match(/^Usage: zat /, out)
    assert_predicate status, :success?
  end

  def test_unknown_option_is_a_usage_error
    _, err, status = zat("--nope")

    assert_match(/invalid option: --nope/, err)
    assert_equal 2, status.exitstatus
  end

  def test_rendering_is_not_implemented_yet
    _, err, status = zat("README.md")

    assert_match(/not implemented yet/, err)
    assert_equal 1, status.exitstatus
  end

  private

  # Runs the real executable in a child process, which inherits RUBYOPT —
  # so under the CI's --zjit jobs the CLI itself runs with ZJIT too.
  def zat(*args) = Open3.capture3(RbConfig.ruby, "-I", LIB, EXE, *args)
end
