# frozen_string_literal: true

module Zat
  module Terminal
    # What the output can show. Terminal.detect reads it from an IO; build one
    # by hand to render for some other target.
    Capabilities = Data.define(:tty, :columns, :color_depth) do
      def tty? = tty
    end
  end
end
