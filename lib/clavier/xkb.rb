module Clavier
  class Xkb
    DIGITS = "digits".freeze
    DIGITS_LOCK = "FRENCHY_DIGITS_LOCK".freeze
    SHIFTLOCK = "shiftlock".freeze
    DIGITLOCK = "digitlock".freeze
    CAPS = "CAPS".freeze
    LEVEL5_LOCK = "+level5(level5_lock)".freeze

    def initialize(layout) = @layout = layout

    def option = "#{@layout.name}:#{DIGITLOCK}"

    VARIANTS = { "iso" => "ISO", "ansi" => "ANSI" }.freeze

    OPTION_DESCRIPTION =
      "Digit row on the Num Lock state, locked by Shift + Caps Lock".freeze

    def description(shape) = "#{@layout.title} #{shape}"

    def symbols = [ansi, iso, shiftlock, digitlock].join("\n")

    def ansi
      [
        "partial alphanumeric_keys",
        %(xkb_symbols "ansi" {),
        "",
        %(    name[Group1] = "#{description("ANSI")}";),
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

    def digitlock
      [
        "partial modifier_keys",
        %(xkb_symbols "#{DIGITLOCK}" {),
        "",
        line(CAPS, @layout[CAPS]),
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
        %(    name[Group1] = "#{description("ISO")}";),
        "",
        @layout.iso.map { |code, key| line(code, key, verb: "replace key") }.join("\n"),
        "};",
        ""
      ].join("\n")
    end

    def types
      [
        %(partial xkb_types "#{DIGITS}" {),
        "    virtual_modifiers NumLock;",
        "",
        %(    type "#{DIGITS_LOCK}" {),
        "	modifiers = Shift + LevelThree + NumLock;",
        "	map[None] = Level2;",
        "	map[Shift] = Level1;",
        "	map[NumLock] = Level1;",
        "	map[Shift+NumLock] = Level2;",
        "	map[LevelThree] = Level3;",
        "	map[Shift+LevelThree] = Level4;",
        "	map[NumLock+LevelThree] = Level3;",
        "	map[Shift+NumLock+LevelThree] = Level4;",
        %(	level_name[Level1] = "Base";),
        %(	level_name[Level2] = "Digit";),
        %(	level_name[Level3] = "AltGr";),
        %(	level_name[Level4] = "Shift AltGr";),
        "    };",
        "};",
        ""
      ].join("\n")
    end

    GROUPS = 4

    def rules
      tables = ["! layout"] + (1..GROUPS).map { "! layout[#{it}]" }

      lines = ["! include %S/evdev", ""] +
        sections.flat_map { |section, included|
          tables.flat_map { ["#{it} = #{section}", "  #{@layout.name} = #{included}", ""] }
        } + option_rules(tables)

      lines.join("\n")
    end

    def sections = { "types" => "+#{@layout.name}(#{DIGITS})", "compat" => LEVEL5_LOCK }

    def option_rules(tables)
      tables.each_with_index.flat_map { |table, index|
        group = index.zero? ? "" : ":#{index}"
        ["#{table} option = symbols",
         "  * #{option} = +#{@layout.name}(#{DIGITLOCK})#{group}", ""]
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
        "        <description>#{description("ISO")}</description>",
        "        <languageList><iso639Id>fra</iso639Id><iso639Id>eng</iso639Id></languageList>",
        "      </configItem>",
        "      <variantList>",
        VARIANTS.flat_map { |name, label|
          ["        <variant>",
           "          <configItem>",
           "            <name>#{name}</name>",
           "            <shortDescription>#{@layout.short}</shortDescription>",
           "            <description>#{description(label)}</description>",
           "          </configItem>",
           "        </variant>"]
        },
        "      </variantList>",
        "    </layout>",
        "  </layoutList>",
        "  <optionList>",
        %(    <group allowMultipleSelection="true">),
        "      <configItem>",
        "        <name>#{@layout.name}</name>",
        "        <description>#{@layout.title}</description>",
        "      </configItem>",
        "      <option>",
        "        <configItem>",
        "          <name>#{option}</name>",
        "          <description>#{OPTION_DESCRIPTION}</description>",
        "        </configItem>",
        "      </option>",
        "    </group>",
        "  </optionList>",
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
