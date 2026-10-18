# frozen_string_literal: true

require "optparse"

module Zat
  class CLI
    SUCCESS = 0
    FAILURE = 1
    USAGE_ERROR = 2
    STDIN_PATH = "-"
    BANNER = "Usage: zat [options] [FILE...]\nRenders Markdown FILEs (or stdin, also as -) to the terminal."

    def self.start(argv, out: $stdout, err: $stderr, input: $stdin, env: ENV) = new(out:, err:, input:, env:).run(argv)

    def initialize(out:, err:, input:, env:)
      @out = out
      @err = err
      @input = input
      @env = env
    end

    def run(argv)
      options = {color: :auto}
      parser = option_parser(options)
      paths = parser.parse(argv)

      if options[:help]
        @out.puts parser
        SUCCESS
      elsif options[:version]
        @out.puts "zat #{VERSION}"
        SUCCESS
      else
        terminal = Terminal.detect(io: @out, env: @env, color: options[:color], columns: options[:columns])
        render(paths.empty? ? [STDIN_PATH] : paths, terminal, fail_fast: options[:fail])
      end
    rescue OptionParser::ParseError => e
      @err.puts "zat: #{e.message}", BANNER
      USAGE_ERROR
    rescue Errno::EPIPE
      # The reader went away (zat x.md | head): nothing left to do, nothing to report.
      SUCCESS
    end

    private

    def render(paths, terminal, fail_fast:)
      failed = false
      separator = ""
      paths.each do |path|
        unless (source = read(path))
          failed = true
          break if fail_fast
          next
        end

        @out.write(separator, Zat.render(source, terminal:))
        separator = "\n"
      end
      failed ? FAILURE : SUCCESS
    end

    def read(path)
      (path == STDIN_PATH) ? @input.binmode.read : File.binread(path)
    rescue SystemCallError => e
      # Rebuilt from errno to drop Ruby's " @ rb_sysopen - <path>" suffix.
      @err.puts "zat: #{path}: #{SystemCallError.new(nil, e.errno).message}"
      nil
    end

    def option_parser(options)
      OptionParser.new(BANNER) do |opts|
        opts.separator ""
        opts.on("-c", "--columns N", Integer, "Output width (default: the terminal's, $COLUMNS, or 80)") do |columns|
          raise OptionParser::InvalidArgument, "--columns #{columns}" unless columns.positive?

          options[:columns] = columns
        end
        opts.on("--no-color", "Plain text, no escape sequences") { options[:color] = :never }
        opts.on("--ansi", "Colors even when not writing to a terminal") { options[:color] = :always }
        opts.on("--fail", "Stop at the first file that can't be read") { options[:fail] = true }
        opts.on("-h", "--help", "Show this help") { options[:help] = true }
        opts.on("-V", "--version", "Show the version") { options[:version] = true }
      end
    end
  end
end
