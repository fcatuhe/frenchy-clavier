require_relative "keysyms"

module Clavier
  class Compose
    DEFAULT = "/usr/share/X11/locale/en_US.UTF-8/Compose".freeze
    LINE = /\A<Multi_key>\s+((?:<[^>]+>\s*)+):\s*"((?:[^"\\]|\\.)*)"/

    def self.load(path = DEFAULT) = File.exist?(path) ? new(File.read(path)) : nil

    def initialize(text)
      @sequences = {}
      text.each_line do |line|
        match = LINE.match(line) or next
        keys = match[1].scan(/<([^>]+)>/).flatten.map { Keysyms.char(_1) }
        @sequences[keys.join] = unescape(match[2]) unless keys.any?(&:nil?)
      end
    end

    def [](sequence) = @sequences[sequence]

    def doubled
      @doubled ||= @sequences.filter_map { |sequence, output|
        [sequence[0], output] if sequence.size == 2 && sequence[0] == sequence[1]
      }.to_h
    end

    private

    def unescape(text) = text.gsub("\\\\", "\\").gsub('\\"', '"')
  end
end
