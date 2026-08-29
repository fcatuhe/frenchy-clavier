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
      @keys = data.fetch("keys").transform_values { Key.new(_1) }
    end

    def [](code) = @keys[code]

    def each_key(&) = @keys.each(&)

    def characters = @keys.each_value.flat_map(&:characters).to_set

    def free_levels
      @keys.flat_map { |code, key|
        LEVELS.each_with_index.filter_map { |level, i| "#{code} #{level}" if key.levels[i].empty? }
      }
    end

    class Key
      attr_reader :levels

      def initialize(levels)
        @levels = Array.new(4) { levels[_1].to_s }
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

      def xkb_type
        return "FOUR_LEVEL_ALPHABETIC" if case_pair?(0, 1) && case_pair?(2, 3)
        return "FOUR_LEVEL_SEMIALPHABETIC" if case_pair?(0, 1)

        "FOUR_LEVEL"
      end

      private

      DISPLAY = {
        "<dead_circumflex>" => "^", "<dead_diaeresis>" => "\u00A8",
        "<dead_caron>" => "\u02C7", "<dead_grave>" => "`", "<dead_acute>" => "\u00B4",
        "<dead_tilde>" => "~", "<dead_cedilla>" => "\u00B8",
        "<space>" => "", "<nobreakspace>" => "nbsp", "<U202F>" => "nnbsp"
      }.freeze

      def case_pair?(low, high)
        a = @levels[low]
        b = @levels[high]
        a.size == 1 && b.size == 1 && a.match?(/\p{Lower}/) && a.upcase == b
      end
    end
  end
end
