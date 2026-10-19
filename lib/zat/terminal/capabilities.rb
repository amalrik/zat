# frozen_string_literal: true

module Zat
  module Terminal
    # What the output can show: built by Terminal.detect, or by hand in tests.
    Capabilities = Data.define(:tty, :columns, :color_depth) do
      def tty? = tty
    end
  end
end
