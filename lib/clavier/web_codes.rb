module Clavier
  module WebCodes
    ROWS = {
      "TLDE" => "Backquote", "BKSL" => "Backslash", "LSGT" => "IntlBackslash",
      "SPCE" => "Space", "CAPS" => "CapsLock", "LFSH" => "ShiftLeft", "RTSH" => "ShiftRight"
    }.freeze

    DIGITS = %w[Digit1 Digit2 Digit3 Digit4 Digit5 Digit6 Digit7 Digit8 Digit9 Digit0 Minus Equal].freeze
    UPPER = %w[KeyQ KeyW KeyE KeyR KeyT KeyY KeyU KeyI KeyO KeyP BracketLeft BracketRight].freeze
    HOME = %w[KeyA KeyS KeyD KeyF KeyG KeyH KeyJ KeyK KeyL Semicolon Quote].freeze
    LOWER = %w[KeyZ KeyX KeyC KeyV KeyB KeyN KeyM Comma Period Slash].freeze

    TABLE = ROWS
      .merge(DIGITS.each_with_index.to_h { |web, i| [format("AE%02d", i + 1), web] })
      .merge(UPPER.each_with_index.to_h { |web, i| [format("AD%02d", i + 1), web] })
      .merge(HOME.each_with_index.to_h { |web, i| [format("AC%02d", i + 1), web] })
      .merge(LOWER.each_with_index.to_h { |web, i| [format("AB%02d", i + 1), web] })
      .freeze

    def self.[](code) = TABLE[code]
  end
end
