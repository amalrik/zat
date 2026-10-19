# frozen_string_literal: true

require "test_helper"
require "open3"
require "tmpdir"
require "zat"

class CLITest < Minitest::Test
  EXE = File.expand_path("../../exe/zat", __dir__)
  LIB = File.expand_path("../../lib", __dir__)
  FIXTURES = File.expand_path("../fixtures", __dir__)
  PARAGRAPHS = "#{FIXTURES}/paragraphs.md"
  RULES = "#{FIXTURES}/thematic_breaks.md"

  def test_version
    out, err, status = zat("--version")

    assert_equal "zat #{Zat::VERSION}\n", out
    assert_empty err
    assert_predicate status, :success?
  end

  def test_help
    out, _, status = zat("--help")

    assert_match(/^Usage: zat /, out)
    assert_match(/--columns N/, out)
    assert_predicate status, :success?
  end

  def test_usage_errors_exit_2
    [%w[--nope], %w[--columns 0], %w[--columns wide]].each do |args|
      _, err, status = zat(*args)

      assert_match(/\Azat: .+\nUsage: zat /, err, args)
      assert_equal 2, status.exitstatus, args
    end
  end

  def test_renders_a_file_without_color_when_piped
    out, err, status = zat(PARAGRAPHS)

    assert_equal File.read("#{FIXTURES}/paragraphs.80.ansi"), out
    assert_empty err
    assert_predicate status, :success?
  end

  def test_renders_several_files_in_order_separated_by_a_blank_line
    out, _, status = zat(PARAGRAPHS, RULES)

    assert_equal render(PARAGRAPHS) + "\n" + render(RULES), out
    assert_predicate status, :success?
  end

  def test_reads_stdin_with_no_arguments_or_a_dash
    [[], ["-"]].each do |args|
      out, _, status = zat(*args, stdin_data: "# Hi\n")

      assert_equal "Hi\n#{"━" * 80}\n", out, args
      assert_predicate status, :success?
    end
  end

  def test_invalid_utf8_is_replaced_not_fatal
    out, _, status = zat(stdin_data: "caf\xE9\n")

    assert_equal "caf�\n", out
    assert_predicate status, :success?
  end

  def test_unreadable_files_are_reported_and_the_rest_still_render
    out, err, status = zat("nope.md", PARAGRAPHS, FIXTURES)

    assert_equal render(PARAGRAPHS), out
    assert_equal "zat: nope.md: No such file or directory\nzat: #{FIXTURES}: Is a directory\n", err
    assert_equal 1, status.exitstatus
  end

  def test_fail_stops_at_the_first_unreadable_file
    out, err, status = zat("--fail", "nope.md", PARAGRAPHS)

    assert_empty out
    assert_equal "zat: nope.md: No such file or directory\n", err
    assert_equal 1, status.exitstatus
  end

  def test_columns_sets_the_width
    out, = zat("--columns", "5", stdin_data: "---\n")

    assert_equal "─────\n", out
  end

  def test_ansi_forces_color_into_a_pipe_and_no_color_wins_when_last
    assert_includes zat("--ansi", stdin_data: "# a\n", env: {"NO_COLOR" => "1"}).first, "\e["
    refute_includes zat("--ansi", "--no-color", stdin_data: "# a\n").first, "\e["
  end

  def test_a_closed_pipe_is_not_an_error
    Dir.mktmpdir do |dir|
      big = File.join(dir, "big.md")
      # Well past the pipe buffer, so the write is still going when head exits.
      File.write(big, "Some paragraph text.\n\n" * 10_000)
      errors = File.join(dir, "stderr")

      Open3.pipeline_r([*command(big), err: errors], %w[head -1]) do |out, threads|
        assert_equal "Some paragraph text.\n", out.read
        assert_predicate threads.first.value, :success?
      end
      assert_empty File.read(errors)
    end
  end

  private

  # The child inherits RUBYOPT, so in the --zjit CI jobs the CLI runs under ZJIT too.
  def command(*args) = [RbConfig.ruby, "-I", LIB, EXE, *args]

  def zat(*args, stdin_data: "", env: {}) = Open3.capture3(env, *command(*args), stdin_data:)

  def render(path) = Zat.render(File.read(path), terminal: Zat::Terminal::Capabilities.new(tty: false, columns: 80, color_depth: :none))
end
