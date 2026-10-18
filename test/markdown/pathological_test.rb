# frozen_string_literal: true

require "test_helper"
require "zat/markdown"

# Inputs that make a naive inline parser quadratic, after cmark's
# test/pathological_tests.py. 16x the input may take 16x longer, not the
# 64x of n^1.5 (naive backtick matching) or 256x of quadratic.
class PathologicalTest < Minitest::Test
  SIZE = 1_000
  GROWTH = 16
  MAX_SLOWDOWN = 32

  def test_backtick_runs_without_closers
    assert_linear { |n| (1..Integer.sqrt(n * 20)).map { "e#{"`" * it}" }.join }
  end

  def test_unclosed_html_constructs
    ["<!--", "<?", "<![CDATA[", "<!A"].each do |opener|
      assert_linear(opener) { |n| "a #{opener} " * n }
    end
  end

  def test_unclosed_angle_brackets_and_entities
    assert_linear { |n| "<a b=\"c\" " * n }
    assert_linear { |n| "&#x" * n }
  end

  # The emphasis cases from cmark's suite; links and brackets come with them.
  def test_emphasis_delimiters
    {
      "openers without closers" => ->(n) { "_a " * n },
      "closers without openers" => ->(n) { "a_ " * n },
      "mismatched openers and closers" => ->(n) { "*a_ " * n },
      "openers and closers multiple of 3" => ->(n) { "a**b" + "c* " * n },
      "nested strong emphasis" => ->(n) { "*a **a " * n + "b" + " a** a*" * n },
      "intraword runs" => ->(n) { "a*" * n },
      "strikethrough of mixed lengths" => ->(n) { "~a ~~b " * n }
    }.each { |label, source| assert_linear(label) { source.call(it) } }
  end

  private

  def assert_linear(label = nil)
    small, large = [SIZE, SIZE * GROWTH].map { |n| best_time(yield(n)) }

    assert_operator large / small, :<, MAX_SLOWDOWN, "#{label} took #{(large / small).round(1)}x as long for #{GROWTH}x the input"
  end

  def best_time(source)
    Array.new(3) {
      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      Zat::Markdown.parse(source)
      Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
    }.min
  end
end
