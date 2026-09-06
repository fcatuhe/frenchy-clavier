require "set"
require_relative "compose"
require_relative "keysyms"
require_relative "mac_codes"

module Clavier
  class Keylayout
    IDS = { "iso" => -19311, "ansi" => -19312 }.freeze
    GROUP = 126
    DTD = "file://localhost/System/Library/DTDs/KeyboardLayout.dtd".freeze
    NONE = "none".freeze

    Map = Struct.new(:keys, :pair, :shift, :caps) do
      def level(key)
        return 0 if key.one_level?

        base = key.two_levels? ? 0 : pair
        base + ((shift ^ (caps && key.cased?(base))) ? 1 : 0)
      end
    end

    MAPS = [
      Map.new("command? anyControl?", 0, false, false),
      Map.new("anyShift command? anyControl?", 0, true, false),
      Map.new("anyOption command? anyControl?", 2, false, false),
      Map.new("anyOption anyShift command? anyControl?", 2, true, false),
      Map.new("caps command? anyControl?", 0, false, true),
      Map.new("caps anyShift command? anyControl?", 0, true, true),
      Map.new("caps anyOption command? anyControl?", 2, false, true),
      Map.new("caps anyOption anyShift command? anyControl?", 2, true, true)
    ].freeze

    SPECIAL = { "Return" => "\r" }.freeze

    def initialize(layout, variant:, compose: Compose.load)
      @layout = layout
      @variant = variant
      @compose = compose
      @keys = layout.each_key.to_h
      @keys = @keys.merge(layout.iso) if iso?
    end

    def iso? = @variant == "iso"

    def name = "#{@layout.title}, #{@variant.upcase}"

    def to_s
      [header, layouts, modifier_map, key_map_set, actions, terminators, "</keyboard>", ""].join("\n")
    end

    private

    def header
      [%(<?xml version="1.0" encoding="UTF-8"?>),
       %(<!DOCTYPE keyboard SYSTEM "#{DTD}">),
       %(<keyboard group="#{GROUP}" id="#{IDS.fetch(@variant)}" name="#{escape(name)}" maxout="#{maxout}">)].join("\n")
    end

    def maxout = (typable + tables.values.flat_map(&:values) + terminator_outputs).map(&:size).max

    def layouts
      ["    <layouts>",
       %(        <layout first="0" last="255" modifiers="modifiers" mapSet="#{@layout.name}"/>),
       "    </layouts>"].join("\n")
    end

    def modifier_map
      selects = MAPS.each_with_index.map { |map, index|
        [%(        <keyMapSelect mapIndex="#{index}">),
         %(            <modifier keys="#{map.keys}"/>),
         "        </keyMapSelect>"]
      }

      [%(    <modifierMap id="modifiers" defaultIndex="0">), selects, "    </modifierMap>"].flatten.join("\n")
    end

    def key_map_set
      maps = MAPS.each_with_index.map { |map, index|
        [%(        <keyMap index="#{index}">), key_lines(map), "        </keyMap>"]
      }

      [%(    <keyMapSet id="#{@layout.name}">), maps, "    </keyMapSet>"].flatten.join("\n")
    end

    def key_lines(map)
      @keys.filter_map { |code, key|
        mac = MacCodes[code, iso: iso?] or next
        [mac, key_line(mac, key, map.level(key))]
      }.sort_by(&:first).filter_map(&:last)
    end

    def key_line(mac, key, level)
      return key_tag(mac, "action", key.levels[level][1..-2]) if key.dead?(level)

      character = character(key.levels[level]) or return nil
      return key_tag(mac, "action", Keysyms.of(character)) if composed.include?(character)

      key_tag(mac, "output", character)
    end

    def key_tag(mac, attribute, value) = %(            <key code="#{mac}" #{attribute}="#{escape(value)}"/>)

    def character(level)
      return nil if level.empty?
      return level unless Keysyms.named?(level)

      name = level[1..-2]
      SPECIAL[name] || Keysyms.char(name)
    end

    def actions
      entries = dead_names.map { dead_action(it) } + composed.sort.map { character_action(it) }

      ["    <actions>", entries, "    </actions>"].flatten.join("\n")
    end

    def dead_action(dead)
      [%(        <action id="#{dead}">),
       %(            <when state="#{NONE}" next="#{dead}"/>),
       "        </action>"]
    end

    def character_action(character)
      whens = tables.filter_map { |dead, table|
        %(            <when state="#{dead}" output="#{escape(table.fetch(character))}"/>) if table[character]
      }

      [%(        <action id="#{Keysyms.of(character)}">),
       %(            <when state="#{NONE}" output="#{escape(character)}"/>),
       whens,
       "        </action>"]
    end

    def terminators
      entries = dead_names.zip(terminator_outputs).map { |dead, output|
        %(        <when state="#{dead}" output="#{escape(output)}"/>)
      }

      ["    <terminators>", entries, "    </terminators>"].flatten.join("\n")
    end

    def terminator_outputs
      dead_names.map { @compose.dead(it)[" "] || raise("#{it} has nothing to fall back on") }
    end

    def dead_names
      @dead_names ||= @keys.each_value.flat_map { |key| key.levels.grep(/\A<dead_/) }.uniq.map { it[1..-2] }
    end

    def tables
      @tables ||= dead_names.to_h { |dead| [dead, @compose.dead(dead).slice(*typable)] }
    end

    def typable = @typable ||= @keys.each_value.flat_map(&:characters).uniq

    def composed = @composed ||= tables.values.flat_map(&:keys).to_set

    ESCAPES = { "&" => "&amp;", "<" => "&lt;", ">" => "&gt;", '"' => "&quot;", "\r" => "&#x000D;" }.freeze

    def escape(text) = text.gsub(/[&<>"\r]/) { ESCAPES.fetch(it) }
  end
end
