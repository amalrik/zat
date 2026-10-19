# frozen_string_literal: true

module Zat
  module Markdown
    class InlineParser
      # Backslash escapes and entity references, spec sections 2.4 and 2.5.
      module Escapes
        ESCAPABLE = /\\(?<escaped>[!-\/:-@\[-`{-~])/
        ENTITY = /&(?:#[xX](?<hex>\h{1,6})|#(?<decimal>\d{1,7})|(?<name>[A-Za-z][A-Za-z0-9]{1,31}));/
        UNESCAPE = /#{ESCAPABLE}|#{ENTITY}/
        REPLACEMENT_CHARACTER = 0xFFFD.chr(Encoding::UTF_8).freeze
        MAX_CODEPOINT = 0x10FFFF
        SURROGATES = 0xD800..0xDFFF

        class << self
          # For text that gets no other inline parsing: info strings, link
          # destinations and titles.
          def unescape(raw)
            raw.gsub(UNESCAPE) do
              match = Regexp.last_match
              match[:escaped] || decode(match) || match[0]
            end
          end

          # The decoded entity at the scanner, or a literal `&`.
          def entity(scanner)
            decoded = decode(scanner) if scanner.check(ENTITY)
            return scanner.getch unless decoded

            scanner.pos += scanner.matched_size
            decoded
          end

          private

          # Takes a MatchData or a StringScanner that just matched ENTITY. nil
          # for an unknown name, which then stays as literal text.
          def decode(match)
            return ENTITIES[match[:name]] if match[:name]

            codepoint = match[:hex] ? match[:hex].to_i(16) : match[:decimal].to_i
            valid = codepoint.positive? && codepoint <= MAX_CODEPOINT && !SURROGATES.cover?(codepoint)
            valid ? codepoint.chr(Encoding::UTF_8) : REPLACEMENT_CHARACTER
          end
        end
      end
    end
  end
end
