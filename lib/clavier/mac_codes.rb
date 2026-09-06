module Clavier
  module MacCodes
    SECTION = 10
    GRAVE = 50

    ROWS = { "TLDE" => GRAVE, "BKSL" => 42, "SPCE" => 49 }.freeze

    DIGITS = [18, 19, 20, 21, 23, 22, 26, 28, 25, 29, 27, 24].freeze
    UPPER = [12, 13, 14, 15, 17, 16, 32, 34, 31, 35, 33, 30].freeze
    HOME = [0, 1, 2, 3, 5, 4, 38, 40, 37, 41, 39].freeze
    LOWER = [6, 7, 8, 9, 11, 45, 46, 43, 47, 44].freeze

    TABLE = ROWS
      .merge(DIGITS.each_with_index.to_h { |code, i| [format("AE%02d", i + 1), code] })
      .merge(UPPER.each_with_index.to_h { |code, i| [format("AD%02d", i + 1), code] })
      .merge(HOME.each_with_index.to_h { |code, i| [format("AC%02d", i + 1), code] })
      .merge(LOWER.each_with_index.to_h { |code, i| [format("AB%02d", i + 1), code] })
      .freeze

    # INFO: fc 06sep26 Apple ISO hardware swaps the two: 10 is top left, 50 sits left of Z
    ISO = { "TLDE" => SECTION, "LSGT" => GRAVE }.freeze

    def self.[](code, iso: false) = (iso && ISO[code]) || TABLE[code]
  end
end
