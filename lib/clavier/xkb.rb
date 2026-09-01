module Clavier
  class Xkb
    LED = "leddigits".freeze
    DIGITS_LOCK = "FRENCHY_DIGITS_LOCK".freeze
    SHIFTLOCK = "shiftlock".freeze
    SHIFTLOCK_OPTION = "shift:frenchy_capslock".freeze

    def initialize(layout) = @layout = layout

    VARIANTS = { "iso" => "ISO", "ansi" => "ANSI" }.freeze

    def symbols = [ansi, iso, shiftlock].join("\n")

    def ansi
      [
        "partial alphanumeric_keys",
        %(xkb_symbols "ansi" {),
        "",
        %(    name[Group1] = "#{@layout.title}, ANSI";),
        "",
        key_lines,
        "",
        %(    include "#{@layout.name}(#{SHIFTLOCK})"),
        %(    include "level3(ralt_switch)"),
        %(    include "keypad(oss)"),
        "};",
        ""
      ].join("\n")
    end

    def shiftlock
      [
        "partial modifier_keys",
        %(xkb_symbols "#{SHIFTLOCK}" {),
        "",
        acting_lines,
        "};",
        ""
      ].join("\n")
    end

    def iso
      [
        "default partial alphanumeric_keys",
        %(xkb_symbols "iso" {),
        "",
        %(    include "#{@layout.name}(ansi)"),
        "",
        %(    name[Group1] = "#{@layout.title}, ISO";),
        "",
        @layout.iso.map { |code, key| line(code, key, verb: "replace key") }.join("\n"),
        "};",
        ""
      ].join("\n")
    end

    def types
      [
        %(partial xkb_types "#{LED}" {),
        %(    type "#{DIGITS_LOCK}" {),
        "	modifiers = Shift + LevelThree + LevelFive;",
        "	map[None] = Level1;",
        "	map[Shift] = Level2;",
        "	map[LevelFive] = Level2;",
        "	map[Shift+LevelFive] = Level1;",
        "	map[LevelThree] = Level3;",
        "	map[Shift+LevelThree] = Level4;",
        "	map[LevelFive+LevelThree] = Level3;",
        "	map[Shift+LevelFive+LevelThree] = Level4;",
        %(	level_name[Level1] = "Base";),
        %(	level_name[Level2] = "Digit";),
        %(	level_name[Level3] = "AltGr";),
        %(	level_name[Level4] = "Shift AltGr";),
        "    };",
        "};",
        ""
      ].join("\n")
    end

    INDICATOR = "Scroll Lock".freeze

    def compat
      [
        %(partial xkb_compatibility "#{LED}" {),
        %(    indicator "#{INDICATOR}" {),
        "\twhichModState= Locked;",
        "\tmodifiers= LevelFive;",
        "    };",
        "};",
        ""
      ].join("\n")
    end

    GROUPS = 4

    SECTIONS = %w[types compat].freeze

    def rules
      tables = ["! layout"] + (1..GROUPS).map { "! layout[#{it}]" }

      lines = ["! include %S/evdev", ""] +
        SECTIONS.flat_map { |section|
          tables.flat_map { ["#{it} = #{section}", "  #{@layout.name} = +#{@layout.name}(#{LED})", ""] }
        } + option_rules(tables)

      lines.join("\n")
    end

    def option_rules(tables)
      tables.each_with_index.flat_map { |table, index|
        group = index.zero? ? "" : ":#{index}"
        ["#{table} option = symbols",
         "  * #{SHIFTLOCK_OPTION} = +#{@layout.name}(#{SHIFTLOCK})#{group}", ""]
      }
    end

    def registry
      [
        %(<?xml version="1.0" encoding="UTF-8"?>),
        %(<!DOCTYPE xkbConfigRegistry SYSTEM "xkb.dtd">),
        %(<xkbConfigRegistry version="1.1">),
        "  <layoutList>",
        "    <layout>",
        "      <configItem>",
        "        <name>#{@layout.name}</name>",
        "        <shortDescription>#{@layout.short}</shortDescription>",
        "        <description>#{@layout.title}, ISO</description>",
        "        <languageList><iso639Id>fra</iso639Id><iso639Id>eng</iso639Id></languageList>",
        "      </configItem>",
        "      <variantList>",
        VARIANTS.flat_map { |name, label|
          ["        <variant>",
           "          <configItem>",
           "            <name>#{name}</name>",
           "            <shortDescription>#{@layout.short}</shortDescription>",
           "            <description>#{@layout.title}, #{label}</description>",
           "          </configItem>",
           "        </variant>"]
        },
        "      </variantList>",
        "    </layout>",
        "  </layoutList>",
        "</xkbConfigRegistry>",
        ""
      ].join("\n")
    end

    private

    def key_lines
      plain = @layout.each_key.reject { |_, key| key.blank? || key.actions }
      plain.map { |code, key| line(code, key) }.join("\n")
    end

    def acting_lines
      acting = @layout.each_key.select { |_, key| key.actions }
      acting.map { |code, key| acting_line(code, key) }.join("\n")
    end

    def line(code, key, verb: "key")
      return acting_line(code, key) if key.actions

      type = key.xkb_type == "FOUR_LEVEL" ? "" : %( type[Group1] = "#{key.xkb_type}",)
      format("    %s <%s> {%s [ %s ] };", verb, code, type, spell(key.keysyms))
    end

    def spell(keysyms)
      filled = keysyms.rindex { _1 != "NoSymbol" } || 0
      keysyms[0..filled].map { _1.ljust(16) }.join(", ").rstrip
    end

    def acting_line(code, key)
      syms = key.keysyms.take(key.actions.size).join(", ")
      format(%(    key <%s> { type[Group1] = "%s", symbols[Group1] = [ %s ], actions[Group1] = [ %s ] };),
        code, key.xkb_type, syms, key.actions.join(", "))
    end
  end
end
