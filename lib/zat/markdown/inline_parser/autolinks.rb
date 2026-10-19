# frozen_string_literal: true

module Zat
  module Markdown
    class InlineParser
      # Spec section 6.5.
      module Autolinks
        URI = /<([A-Za-z][A-Za-z0-9+.-]{1,31}:[^\x00-\x20<>]*)>/
        EMAIL = /<([A-Za-z0-9.!#$%&'*+\/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)*)>/

        class << self
          # A :link node, or nil with the scanner untouched.
          def scan(scanner)
            if scanner.skip(URI)
              link(scanner[1], scanner[1])
            elsif scanner.skip(EMAIL)
              link("mailto:#{scanner[1]}", scanner[1])
            end
          end

          private

          def link(destination, label)
            Node.new(type: :link, attrs: {destination:, autolink: true}, children: [Node.new(type: :text, value: label)])
          end
        end
      end
    end
  end
end
