require_relative "keysyms"

module Clavier
  class Compose
    DEFAULT = "/usr/share/X11/locale/en_US.UTF-8/Compose".freeze
    LINE = /\A\s*((?:<[^>]+>\s*)+):\s*"((?:[^"\\]|\\.)*)"/

    def self.load(path = DEFAULT) = File.exist?(path) ? new(File.read(path)) : nil

    def initialize(text)
      @sequences = {}
      @dead = Hash.new { |hash, key| hash[key] = {} }

      text.each_line do |line|
        match = LINE.match(line) or next
        names = match[1].scan(/<([^>]+)>/).flatten
        record(names, unescape(match[2]))
      end

      @dead.each_value(&:freeze)
    end

    def [](sequence) = @sequences[sequence]

    def dead(keysym) = @dead[keysym]

    def dead_keys = @dead.keys

    def doubled
      @doubled ||= @sequences.filter_map { |sequence, output|
        [sequence[0], output] if sequence.size == 2 && sequence[0] == sequence[1]
      }.to_h
    end

    private

    def record(names, output)
      head, *rest = names
      return multi(rest, output) if head == "Multi_key"
      return unless head.start_with?("dead_") && rest.size == 1

      typed = Keysyms.char(rest.first) or return
      @dead[head][typed] = output
    end

    def multi(names, output)
      typed = names.map { Keysyms.char(_1) }
      @sequences[typed.join] = output unless typed.any?(&:nil?)
    end

    def unescape(text) = text.gsub("\\\\", "\\").gsub('\\"', '"')
  end
end
