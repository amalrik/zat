# frozen_string_literal: true

require "strscan"

# Handlers get the scanner the parser uses, positioned on the character that
# triggered them.
module Scanning
  def scanner(source, at: 0)
    StringScanner.new(source, fixed_anchor: true).tap { it.pos = at }
  end

  # The handler's result and the text it left unread.
  def handled(source, at: 0)
    s = scanner(source, at:)
    [yield(s), s.rest]
  end
end
