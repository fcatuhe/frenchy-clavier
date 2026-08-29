module Clavier
  module Keysyms
    NAMES = {
      " " => "space", "!" => "exclam", "\"" => "quotedbl", "#" => "numbersign",
      "$" => "dollar", "%" => "percent", "&" => "ampersand", "'" => "apostrophe",
      "(" => "parenleft", ")" => "parenright", "*" => "asterisk", "+" => "plus",
      "," => "comma", "-" => "minus", "." => "period", "/" => "slash",
      "0" => "0", "1" => "1", "2" => "2", "3" => "3", "4" => "4",
      "5" => "5", "6" => "6", "7" => "7", "8" => "8", "9" => "9",
      ":" => "colon", ";" => "semicolon", "<" => "less", "=" => "equal",
      ">" => "greater", "?" => "question", "@" => "at",
      "[" => "bracketleft", "\\" => "backslash", "]" => "bracketright",
      "^" => "asciicircum", "_" => "underscore", "`" => "grave",
      "{" => "braceleft", "|" => "bar", "}" => "braceright", "~" => "asciitilde",
      "\u00A0" => "nobreakspace", "´" => "acute", "¨" => "diaeresis", "°" => "degree", "±" => "plusminus",
      "²" => "twosuperior", "µ" => "mu", "×" => "multiply", "÷" => "division",
      "£" => "sterling", "€" => "EuroSign", "§" => "section",
      "«" => "guillemotleft", "»" => "guillemotright",
      "¡" => "exclamdown", "¿" => "questiondown",
      "—" => "emdash", "–" => "endash", "…" => "ellipsis", "·" => "periodcentered",
      "à" => "agrave", "À" => "Agrave", "â" => "acircumflex", "Â" => "Acircumflex",
      "ç" => "ccedilla", "Ç" => "Ccedilla", "é" => "eacute", "É" => "Eacute",
      "è" => "egrave", "È" => "Egrave", "ê" => "ecircumflex", "Ê" => "Ecircumflex",
      "ù" => "ugrave", "Ù" => "Ugrave", "æ" => "ae", "Æ" => "AE",
      "œ" => "oe", "Œ" => "OE", "ß" => "ssharp"
    }.freeze

    NAMED = /\A<[A-Za-z0-9_]+>\z/

    def self.named?(value) = value.match?(NAMED)

    def self.of(char)
      return nil if char.nil? || char.empty?
      return char[1..-2] if named?(char)

      NAMES[char] || (char.size == 1 && char.ord < 128 ? char : unicode(char))
    end

    def self.unicode(char)
      format("U%04X", char.codepoints.first)
    end
  end
end
