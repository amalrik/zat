# frozen_string_literal: true

require "optparse"

module Zat
  class CLI
    def self.start(argv, out: $stdout, err: $stderr) = new(out:, err:).run(argv)

    def initialize(out:, err:)
      @out = out
      @err = err
    end

    # Returns the process exit status. --help and --version throw :exit to
    # stop option parsing early.
    def run(argv)
      catch(:exit) do
        parser.parse(argv)
        @err.puts "zat: rendering is not implemented yet"
        1
      end
    rescue OptionParser::ParseError => e
      @err.puts "zat: #{e.message}", parser.banner
      2
    end

    private

    def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: zat [options] [FILE...]"
        opts.on("-h", "--help", "Show this help") { @out.puts opts; throw :exit, 0 }
        opts.on("-V", "--version", "Show the version") { @out.puts "zat #{VERSION}"; throw :exit, 0 }
      end
    end
  end
end
