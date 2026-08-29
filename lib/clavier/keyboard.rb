module Clavier
  Slot = Struct.new(:code, :label, :width, :stack, keyword_init: true)

  module Keyboard
    ROW_UNITS = 15.0

    def self.rows
      [
        function_row,
        digit_row,
        upper_row,
        home_row,
        lower_row,
        bottom_row
      ]
    end

    def self.fixed(label, width = 1.0) = Slot.new(label: label, width: width)
    def self.key(code, width = 1.0) = Slot.new(code: code, width: width)

    def self.function_row
      labels = %w[Esc F1 F2 F3 F4 F5 F6 F7 F8 F9 F10 F11 F12 Home End Del]
      labels.map { fixed(it, ROW_UNITS / labels.size) }
    end

    def self.digit_row
      %w[TLDE AE01 AE02 AE03 AE04 AE05 AE06 AE07 AE08 AE09 AE10 AE11 AE12].map { key(it) } +
        [fixed("Backspace", 2.0)]
    end

    def self.upper_row
      [fixed("Tab", 1.5)] +
        %w[AD01 AD02 AD03 AD04 AD05 AD06 AD07 AD08 AD09 AD10 AD11 AD12].map { key(it) } +
        [key("BKSL", 1.5)]
    end

    def self.home_row
      [fixed("Caps", 1.75)] +
        %w[AC01 AC02 AC03 AC04 AC05 AC06 AC07 AC08 AC09 AC10 AC11].map { key(it) } +
        [fixed("Enter", 2.25)]
    end

    def self.lower_row
      [fixed("Shift", 2.25)] +
        %w[AB01 AB02 AB03 AB04 AB05 AB06 AB07 AB08 AB09 AB10].map { key(it) } +
        [fixed("Shift", 2.75)]
    end

    def self.bottom_row
      [
        fixed("Ctrl"), fixed("Fn"), fixed("Super"), fixed("Alt", 1.25),
        key("SPCE", 5.25),
        fixed("AltGr", 1.25), fixed("PrtSc"), fixed("Ctrl"),
        Slot.new(width: 0.75, stack: ["PgUp", "\u2190"]),
        Slot.new(width: 0.75, stack: ["\u2191", "\u2193"]),
        Slot.new(width: 0.75, stack: ["PgDn", "\u2192"])
      ]
    end
  end
end
