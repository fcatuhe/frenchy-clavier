require "erb"
require_relative "keyboard"

module Clavier
  class Sheet
    TEMPLATE = File.expand_path("sheet.html.erb", __dir__)

    def initialize(layout) = @layout = layout

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
  end
end
