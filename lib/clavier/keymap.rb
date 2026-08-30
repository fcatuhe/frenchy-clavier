require "json"
require "yaml"
require_relative "compose"
require_relative "web_codes"

module Clavier
  class Keymap
    MODIFIER_KEYSYMS = %w[Multi_key ISO_Level5_Lock Shift_L Shift_R Caps_Lock Return].freeze
    LETTERS = "aeiouycnAEIOUYCN".freeze

    def initialize(layout, compose_path: nil)
      @layout = layout
      @compose = Compose.load
      @curated = compose_path && File.exist?(compose_path) ? YAML.safe_load_file(compose_path).fetch("sequences") : []
    end

    attr_reader :layout, :compose

    def to_json(*) = JSON.generate(keys: keys, dead: dead_tables, deadSpacing: spacing, compose: sequences)

    def dead_keys
      @dead_keys ||= layout.each_key.flat_map { |_, key|
        key.levels.grep(/\A<dead_/).map { it[1..-2] }
      }.uniq
    end

    def spacing = dead_keys.to_h { [it, compose.dead(it)[" "] || ""] }

    def produced(name) = compose.dead(name).select { |typed, _| LETTERS.include?(typed) }

    def combinations(name) = compose.dead(name).size

    def stroke(name)
      layout.each_key do |_, key|
        index = key.levels.index("<#{name}>") or next
        return Layout::MODIFIERS[index] + printed(key)
      end
      name
    end

    def printed(key)
      level = (0..3).find { |index| !key.levels[index].empty? && !key.dead?(index) }
      level ? key.glyph(level) : ""
    end

    def table
      @curated.map { |sequence|
        output = compose[sequence] or raise("no Compose sequence for #{sequence.inspect}")
        [sequence, sequence.chars.map { layout.keystroke(it) || it }.join("  "), output]
      }
    end

    def doubled(character)
      compose.doubled[character] if compose && character.size == 1
    end

    private

    def dead_tables = dead_keys.to_h { [it, compose.dead(it)] }

    def sequences
      doubles = compose.doubled.to_h { |character, output| [character * 2, output] }
      doubles.merge(@curated.to_h { [it, compose[it]] }.compact)
    end

    def keys
      layout.each_key.to_h.merge("LSGT" => layout.iso.fetch("LSGT")).filter_map { |code, entry|
        web = WebCodes[code] or next
        [web, entry.levels.each_with_index.map { |level, index| web_level(entry, level, index) }]
      }.to_h
    end

    def web_level(entry, level, index)
      return nil if level.empty?
      return { d: level[1..-2], g: entry.glyph(index) } if level.start_with?("<dead_")
      return level unless Keysyms.named?(level)

      name = level[1..-2]
      MODIFIER_KEYSYMS.include?(name) ? nil : Keysyms.char(name)
    end
  end
end
