# frozen_string_literal: true

require "optparse"

module Zat
  class CLI
    def self.start(argv, out: $stdout, err: $stderr) = new(out:, err:).run(argv)

    def initialize(out:, err:)
      @out = out
      @err = err
    end

    # Returns the process exit status.
    def run(argv)
      options = parse(argv)

      if options[:help]
        @out.puts parser
        0
      elsif options[:version]
        @out.puts "zat #{VERSION}"
        0
      else
        @err.puts "zat: rendering is not implemented yet"
        1
      end
    rescue OptionParser::ParseError => e
      @err.puts "zat: #{e.message}", parser.banner
      2
    end

    private

    def parse(argv)
      options = {}
      parser.parse(argv, into: options)
      options
    end

    def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: zat [options] [FILE...]"
        opts.on("-h", "--help", "Show this help")
        opts.on("-V", "--version", "Show the version")
      end
    end
  end
end
