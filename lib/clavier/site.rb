require "erb"
require "json"
require "yaml"
require_relative "boards"
require_relative "compose"
require_relative "web_codes"

module Clavier
  class Site
    TEMPLATES = File.expand_path("site", __dir__)

    PAGES = {
      "index" => "Le clavier",
      "apprendre" => "Apprendre",
      "installer" => "Installer"
    }.freeze

    QUADRANTS = [["base", 0], ["shift", 1], ["altgr", 2], ["altgr-shift", 3]].freeze

    def initialize(layout, compose_path: nil)
      @layout = layout
      @compose = Compose.load
      @curated = compose_path && File.exist?(compose_path) ? YAML.safe_load_file(compose_path).fetch("sequences") : []
    end

    def pages = PAGES.keys.to_h { |name| ["#{name}.html", render_page(name)] }

    def render_page(name)
      @page = name
      @body = render(name)
      render("layout")
    end

    private

    attr_reader :layout, :compose, :page, :body

    def render(name)
      template = File.read(File.join(TEMPLATES, "#{name}.html.erb"))
      ERB.new(template, trim_mode: "-").result(binding)
    end

    def escape(text) = ERB::Util.html_escape(text)

    def boards = Boards.all

    def board_html(board)
      @board = board
      render("board")
    end

    def key(board, code) = layout.on(board)[code]

    def quadrants = QUADRANTS

    def unit_class(width) = "u#{(width * 10_000).round}"

    def board_class(board) = "b-#{board.id}"

    def geometry_css
      widths = boards.flat_map { |board| board.rows.flatten.map(&:width) }.uniq.sort
      slots = boards.flat_map { |board| board.rows.map(&:size) }.uniq.sort

      [
        boards.map { ".#{board_class(it)} { --units: #{format('%.4f', it.units)}; }" },
        widths.map { ".#{unit_class(it)} { --span: #{format('%.4f', it)}; }" },
        slots.map { ".n#{it} { --slots: #{it}; }" }
      ].flatten.join("\n")
    end

    def dead_keys
      @dead_keys ||= layout.each_key.flat_map { |_, key|
        key.levels.select { |level| level.start_with?("<dead_") }.map { |level| level[1..-2] }
      }.uniq
    end

    def dead_spacing = dead_keys.to_h { |name| [name, compose.dead(name)[" "] || ""] }

    def dead_stroke(name)
      layout.each_key do |_, key|
        index = key.levels.index("<#{name}>") or next
        return Layout::MODIFIERS[index] + (key.levels[0].empty? ? "" : key.glyph(0))
      end
      name
    end

    VOWELS = "aeiouycnAEIOUYCN".freeze

    def produced(name) = compose.dead(name).select { |typed, _| VOWELS.include?(typed) }

    def combinations(name) = compose.dead(name).size

    def compose_sequences
      return {} unless compose

      doubled = compose.doubled.to_h { |character, output| [character * 2, output] }
      curated = @curated.to_h { |sequence| [sequence, compose[sequence]] }.compact
      doubled.merge(curated)
    end

    def compose_table
      @curated.map { |sequence|
        output = compose[sequence] or raise("no Compose sequence for #{sequence.inspect}")
        [sequence, sequence.chars.map { layout.keystroke(_1) || _1 }.join("  "), output]
      }
    end

    def composed(board, code, index)
      character = key(board, code).levels[index]
      compose.doubled[character] if compose && character.size == 1
    end

    def keymap_json
      keys = {}
      layout.each_key.to_h.merge("LSGT" => layout.iso.fetch("LSGT")).each do |code, entry|
        web = WebCodes[code] or next
        keys[web] = entry.levels.each_with_index.map { |level, index| web_level(entry, level, index) }
      end

      JSON.generate(keys: keys, dead: dead_keys.to_h { [it, compose.dead(it)] },
        deadSpacing: dead_spacing, compose: compose_sequences)
    end

    MODIFIER_KEYSYMS = %w[Multi_key ISO_Level5_Lock Shift_L Shift_R Caps_Lock Return].freeze

    def web_level(entry, level, index)
      return nil if level.empty?
      return { d: level[1..-2], g: entry.glyph(index) } if level.start_with?("<dead_")
      return level unless Keysyms.named?(level)

      name = level[1..-2]
      MODIFIER_KEYSYMS.include?(name) ? nil : Keysyms.char(name)
    end
  end
end
