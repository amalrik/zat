# frozen_string_literal: true

require "optparse"

module Zat
  class CLI
    SUCCESS = 0
    FAILURE = 1
    USAGE_ERROR = 2

    def self.start(argv, out: $stdout, err: $stderr) = new(out:, err:).run(argv)

    def initialize(out:, err:)
      @out = out
      @err = err
    end

    def run(argv)
      options = parse(argv)

      if options[:help]
        @out.puts parser
        SUCCESS
      elsif options[:version]
        @out.puts "zat #{VERSION}"
        SUCCESS
      else
        @err.puts "zat: rendering is not implemented yet"
        FAILURE
      end
    rescue OptionParser::ParseError => e
      @err.puts "zat: #{e.message}", parser.banner
      USAGE_ERROR
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
