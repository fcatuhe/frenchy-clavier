require_relative "board"

module Clavier
  module Boards
    extend Slots

    ALL = {}

    def self.[](id) = ALL.fetch(id)
    def self.all = ALL.values
    def self.default = ALL.fetch("framework-13-iso")
    def self.define(board) = ALL[board.id] = board

    FRAMEWORK_PITCH = 19.0
    FRAMEWORK_ROW = 280.0
    FRAMEWORK_SOURCE = "Framework Laptop 13 CAD.stp, keycap bounding boxes, (cap + 2,835) / 19".freeze

    def self.framework(mm) = mm / FRAMEWORK_PITCH

    MACBOOK_UNITS = 14.5
    MACBOOK_SOURCE = "touche, barre oblique inverse et Maj mesurées par wellorder.net sur un pas de 19,05 mm ; " \
                     "le reste déduit pour que chaque rangée ferme à 14,5 u".freeze
    MACBOOK_NOTE = "Pas d'AltGr sur un Mac : c'est Option qui tient le troisième niveau.".freeze

    def self.macbook_bottom_row(third)
      [
        fixed("fn"), fixed("control"), fixed(third), fixed("command", 1.25),
        key("SPCE", 5.0),
        fixed("command", 1.25), fixed(third),
        fixed("\u25C0"), cluster(1.0, [["\u25B2"], ["\u25BC"]]), fixed("\u25B6")
      ]
    end

    MACBOOK_FUNCTION_ROW = [
      fixed("esc", 1.5), *(1..12).map { fixed("F#{it}") }, fixed("\u25C9")
    ].freeze

    FRAMEWORK_FUNCTION_ROW = [
      spacer(framework(26)),
      fixed("Esc"), *(1..11).map { fixed("F#{it}") }, fixed("F12", framework(26))
    ].freeze

    FRAMEWORK_BOTTOM_ROW = [
      fixed("Ctrl", framework(24)), fixed("Fn"), fixed("Super"), fixed("Alt"),
      key("SPCE", framework(95)),
      fixed("AltGr"), fixed("Ctrl"),
      cluster(framework(66), [[nil, "\u2191", nil], ["\u2190", "\u2193", "\u2192"]])
    ].freeze

    define Board.new(
      id: "x1-carbon-ansi",
      name: "ThinkPad X1 Carbon Gen 6",
      hardware: "Lenovo",
      shape: :ansi,
      source: "millimètres Lenovo via pfaion/x1carbon-xkb-geometry, (touche + jeu) / 20",
      widths: { backspace: 2.0, backspace_label: "Backspace", tab: 1.45, bksl: 1.55,
                caps: 1.65, enter: 2.35, enter_label: "Enter", lfsh: 2.15, rtsh: 2.85 },
      function_row: [
        fixed("Esc", 1.1625),
        spacer(0.075), *%w[F1 F2 F3 F4].map { fixed(it, 0.825) },
        spacer(0.075), *%w[F5 F6 F7 F8].map { fixed(it, 0.825) },
        spacer(0.075), *%w[F9 F10 F11 F12].map { fixed(it, 0.825) },
        spacer(0.075), *%w[Home End Ins].map { fixed(it, 0.825) }, fixed("Del", 1.1625)
      ],
      bottom_row: [
        fixed("Fn"), fixed("Ctrl", 1.15), fixed("Super"), fixed("Alt"),
        key("SPCE", 5.0),
        fixed("AltGr"), fixed("PrtSc"), fixed("Ctrl"),
        cluster(2.85, [["PgUp", "\u2191", "PgDn"], ["\u2190", "\u2193", "\u2192"]])
      ]
    )

    define Board.new(
      id: "framework-13-ansi",
      name: "Framework Laptop 13",
      hardware: "Framework",
      shape: :ansi,
      source: FRAMEWORK_SOURCE,
      units: framework(FRAMEWORK_ROW),
      widths: { backspace: framework(33), backspace_label: "Backspace",
                tab: framework(28), bksl: framework(24),
                caps: framework(33), enter: framework(38), enter_label: "Enter",
                lfsh: framework(43), rtsh: framework(47) },
      function_row: FRAMEWORK_FUNCTION_ROW,
      bottom_row: FRAMEWORK_BOTTOM_ROW
    )

    define Board.new(
      id: "framework-13-iso",
      name: "Framework Laptop 13",
      hardware: "Framework",
      shape: :iso,
      source: "#{FRAMEWORK_SOURCE} ; Framework ne publie pas de modèle ISO, la touche " \
              "supplémentaire prend son millimètre à Maj gauche et Entrée le sien à sa voisine",
      units: framework(FRAMEWORK_ROW),
      widths: { backspace: framework(33), backspace_label: "Backspace",
                tab: framework(28), caps: framework(33), enter_label: "Enter",
                enter_top: framework(24), enter_bottom: framework(19),
                lfsh: framework(24), rtsh: framework(47) },
      function_row: FRAMEWORK_FUNCTION_ROW,
      bottom_row: FRAMEWORK_BOTTOM_ROW
    )

    define Board.new(
      id: "macbook-us",
      name: "MacBook, clavier US",
      hardware: "Apple",
      shape: :ansi,
      source: MACBOOK_SOURCE,
      units: MACBOOK_UNITS,
      note: MACBOOK_NOTE,
      widths: { backspace: 1.5, backspace_label: "delete", tab: 1.5, bksl: 1.0,
                caps: 1.75, enter: 1.75, enter_label: "return", lfsh: 2.25, rtsh: 2.25 },
      function_row: MACBOOK_FUNCTION_ROW,
      bottom_row: macbook_bottom_row("option")
    )

    define Board.new(
      id: "macbook-fr",
      name: "MacBook, clavier français",
      hardware: "Apple",
      shape: :iso,
      source: "#{MACBOOK_SOURCE} ; l'ISO reprend les proportions ISO standard ramenées à 14,5 u",
      units: MACBOOK_UNITS,
      note: MACBOOK_NOTE,
      widths: { backspace: 1.5, backspace_label: "delete", tab: 1.5,
                caps: 1.5, enter_label: "return", enter_top: 1.0, enter_bottom: 1.0,
                lfsh: 1.25, rtsh: 2.25 },
      function_row: MACBOOK_FUNCTION_ROW,
      bottom_row: macbook_bottom_row("alt")
    )
  end
end
