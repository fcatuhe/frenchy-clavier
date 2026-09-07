module KeyboardsHelper
  QUADRANTS = [ [ "base", 0 ], [ "shift", 1 ], [ "altgr", 2 ], [ "altgr-shift", 3 ] ].freeze

  def boards = Keyboard.all

  def keys_of(board) = Keyboard.layout.on(board)

  def alpha_rows(board) = board.rows.drop(1)

  def quadrants = QUADRANTS

  def unit_class(width) = "u#{(width * 10_000).round}"

  def board_class(board) = "b-#{board.id}"

  def slot_classes(slot)
    [ unit_class(slot.width), ("join-#{slot.join}" if slot.join) ].compact.join(" ")
  end

  def key_classes(slot, key, diff)
    [ slot_classes(slot),
      ("lockable" if key.lockable?),
      ("same" if diff && Clavier::Reference.same_as_azerty?(slot.code, key)) ].compact.join(" ")
  end

  def geometry_css
    drawn = Clavier::Boards.all
    widths = drawn.flat_map { |board| board.rows.flatten.map(&:width) }.uniq.sort

    [
      drawn.map { ".#{board_class(it)} { --units: #{format('%.4f', it.units)}; }" },
      widths.map { ".#{unit_class(it)} { --span: #{format('%.4f', it)}; }" }
    ].flatten.join("\n").html_safe
  end

  def board_shape(board) = board.iso? ? "ISO" : "ANSI"
end
