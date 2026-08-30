require "set"
require "yaml"
require_relative "keysyms"
require_relative "xkb"

module Clavier
  class Layout
    LEVELS = %i[base shift altgr altgr_shift].freeze

    def self.load(path) = new(YAML.safe_load_file(path))

    attr_reader :name, :title, :subtitle, :short

    def initialize(data)
      @name = data.fetch("name")
      @title = data.fetch("title")
      @subtitle = data.fetch("subtitle")
      @short = data.fetch("short")
      types = data["types"] || {}
      actions = data["actions"] || {}
      @keys = data.fetch("keys").to_h { |code, levels| [code, Key.new(levels, types[code], actions[code])] }
      @keys.each_value(&:lockable_digit!) if data["digits_lock"]
      @iso = build(data["iso"] || {})
    end

    attr_reader :iso

    def [](code) = @keys[code]

    def on(board) = board.iso? ? @keys.merge(@iso) : @keys

    def build(section)
      types = section["types"] || {}
      (section["keys"] || {}).to_h { |code, levels| [code, Key.new(levels, types[code])] }
    end

    MODIFIERS = ["", "Maj ", "AltGr ", "AltGr Maj "].freeze

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

      attr_reader :actions

      def initialize(levels, type = nil, actions = nil)
        @levels = Array.new(4) { levels[_1].to_s }
        @type = type
        @actions = actions
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
        return Xkb::DIGITS_LOCK if @lockable
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
        "<Multi_key>" => "Compose", "<ISO_Level5_Lock>" => "chiffres", "<Return>" => "Entrée",
        "<Shift_L>" => "Maj", "<Shift_R>" => "Maj", "<Caps_Lock>" => "Verr. maj."
      }.freeze

      def case_pair?(low, high)
        a = @levels[low]
        b = @levels[high]
        a.size == 1 && b.size == 1 && a.match?(/\p{Lower}/) && a.upcase == b
      end
    end
  end
end
