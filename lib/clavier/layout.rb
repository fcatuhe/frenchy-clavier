require "set"
require "yaml"
require_relative "keysyms"

module Clavier
  class Layout
    LEVELS = %i[base shift altgr altgr_shift].freeze

    def self.load(path) = new(YAML.safe_load_file(path))

    attr_reader :name, :title, :subtitle

    def initialize(data)
      @name = data.fetch("name")
      @title = data.fetch("title")
      @subtitle = data.fetch("subtitle")
      types = data["types"] || {}
      @keys = data.fetch("keys").to_h { |code, levels| [code, Key.new(levels, types[code])] }
      @keys.each_value(&:lockable_digit!) if data["digits_lock"]
    end

    def [](code) = @keys[code]

    MODIFIERS = ["", "Shift ", "AltGr ", "AltGr Shift "].freeze

    def keystroke(char)
      @keys.each do |code, key|
        index = key.levels.index(char) or next
        return MODIFIERS[index] + (key.levels[0].empty? ? code : key.glyph(0))
      end
      nil
    end

    def each_key(&) = @keys.each(&)

    def characters = @keys.each_value.flat_map(&:characters).to_set

    def free_levels
      @keys.flat_map { |code, key|
        LEVELS.each_with_index.filter_map { |level, i| "#{code} #{level}" if key.levels[i].empty? }
      }
    end

    class Key
      attr_reader :levels

      def initialize(levels, type = nil)
        @levels = Array.new(4) { levels[_1].to_s }
        @type = type
      end

      def keysyms = @levels.map { Keysyms.of(_1) || "NoSymbol" }

      def characters = @levels.reject { _1.empty? || Keysyms.named?(_1) }

      def glyph(index)
        raw = @levels[index]
        return raw unless Keysyms.named?(raw)

        DISPLAY.fetch(raw, raw[1..-2])
      end

      def dead?(index) = @levels[index].start_with?("<dead_")

      def blank? = @levels.all?(&:empty?)

      def lockable_digit! = @lockable = @levels[1].match?(/\A[0-9]\z/)

      def xkb_type
        return @type if @type
        return "FOUR_LEVEL_LOCKABLE_LEVEL2" if @lockable
        return "FOUR_LEVEL_ALPHABETIC" if case_pair?(0, 1) && case_pair?(2, 3)
        return "FOUR_LEVEL_SEMIALPHABETIC" if case_pair?(0, 1)

        "FOUR_LEVEL"
      end

      private

      DOTTED = "\u25CC"

      DISPLAY = {
        "<dead_circumflex>" => "#{DOTTED}\u0302", "<dead_diaeresis>" => "#{DOTTED}\u0308",
        "<dead_caron>" => "#{DOTTED}\u030C", "<dead_grave>" => "#{DOTTED}\u0300",
        "<dead_acute>" => "#{DOTTED}\u0301", "<dead_tilde>" => "#{DOTTED}\u0303",
        "<dead_cedilla>" => "#{DOTTED}\u0327",
        "<space>" => "", "<nobreakspace>" => "nbsp", "<U202F>" => "nnbsp",
        "<Multi_key>" => "Compose", "<ISO_Level5_Lock>" => "digits lock",
        "<Shift_L>" => "Shift", "<Shift_R>" => "Shift", "<Caps_Lock>" => "Caps Lock"
      }.freeze

      def case_pair?(low, high)
        a = @levels[low]
        b = @levels[high]
        a.size == 1 && b.size == 1 && a.match?(/\p{Lower}/) && a.upcase == b
      end
    end
  end
end
