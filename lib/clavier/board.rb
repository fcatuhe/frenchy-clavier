module Clavier
  Slot = Struct.new(:code, :label, :width, :cluster, :spacer, :join, keyword_init: true) do
    def key? = !code.nil?
  end

  module Slots
    module_function

    def key(code, width = 1.0) = Slot.new(code: code, width: width)
    def keys(*codes) = codes.map { key(it) }
    def fixed(label, width = 1.0) = Slot.new(label: label, width: width)
    def spacer(width) = Slot.new(width: width, spacer: true)
    def joined(label, width, join) = Slot.new(label: label, width: width, join: join)
    def cluster(width, rows) = Slot.new(width: width, cluster: rows)
  end

  module Alpha
    extend Slots

    DIGITS = %w[TLDE AE01 AE02 AE03 AE04 AE05 AE06 AE07 AE08 AE09 AE10 AE11 AE12].freeze
    UPPER = %w[AD01 AD02 AD03 AD04 AD05 AD06 AD07 AD08 AD09 AD10 AD11 AD12].freeze
    HOME = %w[AC01 AC02 AC03 AC04 AC05 AC06 AC07 AC08 AC09 AC10 AC11].freeze
    LOWER = %w[AB01 AB02 AB03 AB04 AB05 AB06 AB07 AB08 AB09 AB10].freeze

    def self.rows(shape, widths) = [digit_row(widths), *send(shape, widths)]

    def self.digit_row(w) = [*keys(*DIGITS), fixed(w.fetch(:backspace_label), w.fetch(:backspace))]

    def self.ansi(w)
      [
        [fixed("Tab", w.fetch(:tab)), *keys(*UPPER), key("BKSL", w.fetch(:bksl))],
        [key("CAPS", w.fetch(:caps)), *keys(*HOME), fixed(w.fetch(:enter_label), w.fetch(:enter))],
        [key("LFSH", w.fetch(:lfsh)), *keys(*LOWER), key("RTSH", w.fetch(:rtsh))]
      ]
    end

    def self.iso(w)
      [
        [fixed("Tab", w.fetch(:tab)), *keys(*UPPER), joined(w.fetch(:enter_label), w.fetch(:enter_top), :below)],
        [key("CAPS", w.fetch(:caps)), *keys(*HOME), key("BKSL"), joined(nil, w.fetch(:enter_bottom), :above)],
        [key("LFSH", w.fetch(:lfsh)), key("LSGT"), *keys(*LOWER), key("RTSH", w.fetch(:rtsh))]
      ]
    end
  end

  class Board
    SHAPES = %i[ansi iso].freeze

    attr_reader :id, :name, :hardware, :shape, :source, :units, :note, :rows

    def initialize(id:, name:, hardware:, shape:, source:, widths:, function_row:, bottom_row:, units: 15.0, note: nil)
      raise ArgumentError, "unknown shape #{shape}" unless SHAPES.include?(shape)

      @id, @name, @hardware, @shape, @source, @units, @note = id, name, hardware, shape, source, units, note
      @rows = [function_row, *Alpha.rows(shape, widths), bottom_row].freeze
      freeze
    end

    def iso? = @shape == :iso

    def codes = rows.flatten.filter_map(&:code)

    def function_row = rows.first
  end
end
