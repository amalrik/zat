# frozen_string_literal: true

require "io/console"
require_relative "terminal/capabilities"
require_relative "terminal/palette"
require_relative "terminal/style"

module Zat
  module Terminal
    DEFAULT_COLUMNS = 80

    class << self
      def detect(io: $stdout, env: ENV, color: :auto, columns: nil)
        tty = io.tty?
        Capabilities.new(tty:, columns: columns || detect_columns(io, tty, env), color_depth: detect_color_depth(tty, env, color))
      end

      private

      # An explicit choice (--color) beats NO_COLOR, which beats TTY detection.
      def detect_color_depth(tty, env, color)
        return :none if color == :never
        return :none if color == :auto && (!env.fetch("NO_COLOR", "").empty? || !tty || env["TERM"] == "dumb")

        if %w[truecolor 24bit].include?(env["COLORTERM"]) then :truecolor
        elsif env["TERM"].to_s.include?("256color") then :ansi256
        else :ansi16
        end
      end

      def detect_columns(io, tty, env)
        width = begin
          (tty && io.respond_to?(:winsize)) ? io.winsize.last : 0
        rescue SystemCallError
          0
        end
        width = env["COLUMNS"].to_i unless width.positive?
        width.positive? ? width : DEFAULT_COLUMNS
      end
    end
  end
end
