# frozen_string_literal: true

module Zat
  module Markdown
    class InlineParser
      # Spec section 6.3's bracket stack: where each `[` or `![` sits in the
      # node list, until a `]` settles it.
      class Brackets
        Opener = Data.define(:index, :image)

        def initialize
          @openers = []
          # Links can't contain links: once one closes, every `[` still open
          # below this height is dead.
          @dead_below = 0
        end

        def push(index:, image:) = @openers << Opener.new(index:, image:)

        # The innermost opener, unless there is none or it can no longer start a link.
        def pop
          return if @openers.empty?

          dead = @openers.size <= @dead_below
          opener = @openers.pop
          @dead_below = [@dead_below, @openers.size].min
          opener if opener.image || !dead
        end

        def link_closed
          @dead_below = @openers.size
        end
      end
    end
  end
end
