module Clavier
  class Xkb
    LED = "leddigits".freeze

    def initialize(layout) = @layout = layout

    def symbols
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

    def rules
      ["! include %S/evdev", "", "! layout = compat", "  #{@layout.name} = +#{@layout.name}(#{LED})", ""].join("\n")
    end

    def files = { "symbols" => symbols, "compat" => compat }

    private

    def key_lines
      @layout.each_key.reject { |_, key| key.blank? }.map { |code, key| line(code, key) }.join("\n")
    end

    def line(code, key)
      syms = key.keysyms.map { _1.ljust(16) }.join(", ").rstrip
      type = key.xkb_type == "FOUR_LEVEL" ? "" : %( type[Group1] = "#{key.xkb_type}",)
      format("    key <%s> {%s [ %s ] };", code, type, syms)
    end
  end
end
