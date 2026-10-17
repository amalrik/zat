# frozen_string_literal: true

module Zat
  # Markdown parser, designed to be extracted as a standalone gem later.
  #
  # Must not depend on anything else under Zat:: — test/markdown/ loads it
  # without the rest of the project to keep that boundary honest.
  module Markdown
  end
end
