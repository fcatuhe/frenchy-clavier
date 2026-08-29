module Clavier
  class Xkb
    def initialize(layout) = @layout = layout

    def to_s
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
