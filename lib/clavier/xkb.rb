module Clavier
  class Xkb
    LED = "leddigits".freeze

    def initialize(layout) = @layout = layout

    VARIANTS = { "ansi" => "ANSI", "iso" => "ISO" }.freeze

    def symbols = [base, ansi, iso].join("\n")

    def ansi
      [
        "partial alphanumeric_keys",
        %(xkb_symbols "ansi" {),
        "",
        %(    include "#{@layout.name}(#{@layout.name})"),
        "",
        %(    name[Group1] = "#{@layout.title}, ANSI";),
        "};",
        ""
      ].join("\n")
    end

    def base
      [
        "default partial alphanumeric_keys",
        %(xkb_symbols "#{@layout.name}" {),
        "",
        %(    name[Group1] = "#{@layout.title}";),
        "",
        key_lines,
        "",
        %(    include "level3(ralt_switch)"),
        %(    include "keypad(oss)"),
        "};",
        ""
      ].join("\n")
    end

    def iso
      [
        "partial alphanumeric_keys",
        %(xkb_symbols "iso" {),
        "",
        %(    include "#{@layout.name}(#{@layout.name})"),
        "",
        %(    name[Group1] = "#{@layout.title}, ISO";),
        "",
        %(    replace key <BKSL> { type[Group1] = "ONE_LEVEL", [ Return ] };),
        %(    replace key <LSGT> { type[Group1] = "FOUR_LEVEL", [ backslash, bar, NoSymbol, NoSymbol ] };),
        "};",
        ""
      ].join("\n")
    end

    def compat
      [
        %(partial xkb_compatibility "#{LED}" {),
        %(    indicator "Caps Lock" {),
        "\twhichModState= Locked;",
        "\tmodifiers= Lock+LevelFive;",
        "    };",
        "};",
        ""
      ].join("\n")
    end

    GROUPS = 4

    def rules
      tables = ["! layout"] + (1..GROUPS).map { "! layout[#{it}]" }

      lines = ["! include %S/evdev", ""] +
        tables.flat_map { ["#{it} = compat", "  #{@layout.name} = +#{@layout.name}(#{LED})", ""] }

      lines.join("\n")
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
        "        <description>#{@layout.title}</description>",
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
      @layout.each_key.reject { |_, key| key.blank? }.map { |code, key| line(code, key) }.join("\n")
    end

    def line(code, key)
      return acting_line(code, key) if key.actions

      syms = key.keysyms.map { _1.ljust(16) }.join(", ").rstrip
      type = key.xkb_type == "FOUR_LEVEL" ? "" : %( type[Group1] = "#{key.xkb_type}",)
      format("    key <%s> {%s [ %s ] };", code, type, syms)
    end

    def acting_line(code, key)
      syms = key.keysyms.take(key.actions.size).join(", ")
      format(%(    key <%s> { type[Group1] = "%s", symbols[Group1] = [ %s ], actions[Group1] = [ %s ] };),
        code, key.xkb_type, syms, key.actions.join(", "))
    end
  end
end
