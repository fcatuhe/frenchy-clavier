require "erb"
require "yaml"
require_relative "compose"
require_relative "keyboard"

module Clavier
  class Sheet
    TEMPLATE = File.expand_path("sheet.html.erb", __dir__)

    def initialize(layout, compose_path: nil)
      @layout = layout
      @compose = Compose.load
      @wanted = compose_path && File.exist?(compose_path) ? YAML.safe_load_file(compose_path).fetch("sequences") : []
    end

    def to_s = ERB.new(File.read(TEMPLATE), trim_mode: "-").result(binding)

    private

    attr_reader :layout

    def rows = Keyboard.rows

    def unit_class(width) = "u#{(width * 100).round}"

    def unit_classes
      Keyboard.rows.flatten.map(&:width).uniq.sort.map { |width|
        ".#{unit_class(width)} { --span: #{format('%.4f', width)}; }"
      }.join("\n      ")
    end

    def slot_count_classes
      Keyboard.rows.map(&:size).uniq.sort.map { ".n#{it} { --slots: #{it}; }" }.join("\n      ")
    end

    def escape(text) = ERB::Util.html_escape(text)

    attr_reader :compose

    def composed(code, index)
      key = layout[code]
      character = key.levels[index]
      compose.doubled[character] if compose && character.size == 1
    end

    def compose_table
      return [] unless compose

      @wanted.map { |sequence|
        output = compose[sequence] or raise("no Compose sequence for #{sequence.inspect}")
        [sequence, sequence.chars.map { layout.keystroke(_1) || _1 }.join("  "), output]
      }
    end
  end
end
