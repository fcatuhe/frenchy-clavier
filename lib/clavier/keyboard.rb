module Clavier
  Slot = Struct.new(:code, :label, :width, :cluster, :spacer, keyword_init: true)

  # INFO: fc 29aug26 widths are Lenovo's, from pfaion/x1carbon-xkb-geometry, as (mm + gap) / 20
  module Keyboard
    ROW_UNITS = 15.0

    def self.rows
      [function_row, digit_row, upper_row, home_row, lower_row, bottom_row]
    end

    def self.key(code, width = 1.0) = Slot.new(code: code, width: width)
    def self.fixed(label, width = 1.0) = Slot.new(label: label, width: width)
    def self.spacer(width) = Slot.new(width: width, spacer: true)

    FN_KEY = 0.825
    FN_WIDE = 1.1625
    FN_GROUP = 0.075

    def self.function_row
      groups = [%w[F1 F2 F3 F4], %w[F5 F6 F7 F8], %w[F9 F10 F11 F12], %w[Home End Ins Del]]
      row = [fixed("Esc", FN_WIDE)]
      groups.each do |group|
        row << spacer(FN_GROUP)
        row.concat(group.map { fixed(it, FN_KEY) })
      end
      row[-1] = fixed("Del", FN_WIDE)
      row
    end

    def self.digit_row
      %w[TLDE AE01 AE02 AE03 AE04 AE05 AE06 AE07 AE08 AE09 AE10 AE11 AE12].map { key(it) } +
        [fixed("Backspace", 2.0)]
    end

    def self.upper_row
      [fixed("Tab", 1.45)] +
        %w[AD01 AD02 AD03 AD04 AD05 AD06 AD07 AD08 AD09 AD10 AD11 AD12].map { key(it) } +
        [key("BKSL", 1.55)]
    end

    def self.home_row
      [key("CAPS", 1.65)] +
        %w[AC01 AC02 AC03 AC04 AC05 AC06 AC07 AC08 AC09 AC10 AC11].map { key(it) } +
        [fixed("Enter", 2.35)]
    end

    def self.lower_row
      [key("LFSH", 2.15)] +
        %w[AB01 AB02 AB03 AB04 AB05 AB06 AB07 AB08 AB09 AB10].map { key(it) } +
        [key("RTSH", 2.85)]
    end

    def self.bottom_row
      [
        fixed("Fn"), fixed("Ctrl", 1.15), fixed("Super"), fixed("Alt"),
        key("SPCE", 5.0),
        fixed("AltGr"), fixed("PrtSc"), fixed("Ctrl"),
        Slot.new(width: 2.85, cluster: [["PgUp", "\u2191", "PgDn"], ["\u2190", "\u2193", "\u2192"]])
      ]
    end
  end
end
