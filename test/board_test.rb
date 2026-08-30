require "minitest/autorun"
require_relative "../lib/clavier"

class BoardTest < Minitest::Test
  def setup
    @layout = Clavier::Layout.load(File.expand_path("../layout.yml", __dir__))
  end

  def boards = Clavier::Boards.all

  def test_there_is_a_board_for_every_machine_the_readme_claims
    assert_equal(%w[x1-carbon-ansi framework-13-ansi framework-13-iso macbook-us macbook-fr],
      boards.map(&:id))
  end

  def test_every_row_of_every_board_spans_the_whole_board
    boards.each do |board|
      board.rows.each_with_index do |row, index|
        assert_in_delta(board.units, row.sum(&:width), 0.0001,
          "#{board.id} row #{index} spans #{row.sum(&:width)}u, the board is #{board.units}u")
      end
    end
  end

  def test_no_board_draws_the_same_key_twice
    boards.each { |board| assert_equal(board.codes, board.codes.uniq, "#{board.id} repeats a key") }
  end

  def test_every_key_of_the_layout_lands_on_a_slot_of_every_board
    boards.each do |board|
      @layout.on(board).each_key do |code|
        assert_includes(board.codes, code, "#{code} has no key on #{board.id}")
      end
    end
  end

  def test_the_extra_iso_key_exists_on_iso_hardware_and_nowhere_else
    boards.each do |board|
      assert_equal(board.iso?, board.codes.include?("LSGT"), "LSGT on #{board.id}")
    end
  end

  def test_an_iso_board_reaches_the_backslash_the_ansi_one_lost_to_enter
    iso = Clavier::Boards["framework-13-iso"]

    assert_equal("Entrée", @layout.on(iso)["BKSL"].glyph(0))
    assert_equal("\\", @layout.on(iso)["LSGT"].glyph(0))
    assert_equal("\\", @layout["BKSL"].glyph(0))
  end

  def test_every_board_says_where_its_millimetres_came_from
    boards.each { |board| refute_empty(board.source, "#{board.id} claims a geometry it cannot source") }
  end

  def test_the_framework_closes_on_whole_millimetres_of_its_own_pitch
    board = Clavier::Boards["framework-13-ansi"]

    board.rows.flatten.reject(&:cluster).each do |slot|
      millimetres = slot.width * Clavier::Boards::FRAMEWORK_PITCH

      assert_in_delta(millimetres.round, millimetres, 0.0001, "#{slot.code || slot.label} is not a whole millimetre")
    end
  end
end
