require "minitest/autorun"
require "tmpdir"
require "fileutils"
require_relative "../lib/clavier"

class LayoutTest < Minitest::Test
  ISO_ONLY = %w[LSGT AC12].freeze

  def setup
    @layout = Clavier::Layout.load(File.expand_path("../layout.yml", __dir__))
  end

  def test_every_key_lands_on_a_slot_of_the_ansi_board
    board = Clavier::Keyboard.rows.flatten.filter_map(&:code)

    @layout.each_key { |code, _| assert_includes(board, code, "#{code} has no key on an ANSI X1 Carbon") }
  end

  def test_every_row_spans_the_full_board
    Clavier::Keyboard.rows.each_with_index do |row, index|
      assert_in_delta(Clavier::Keyboard::ROW_UNITS, row.sum(&:width), 0.001, "row #{index} does not span the board")
    end
  end

  def test_no_iso_only_key_is_used
    ISO_ONLY.each { |code| assert_nil(@layout[code], "#{code} does not exist on ANSI hardware") }
  end

  def test_every_ascii_printable_is_reachable
    printable = (33..126).map(&:chr)

    (printable - @layout.characters.to_a).then { assert_empty(it, "unreachable: #{it.join}") }
  end

  def test_a_literal_angle_bracket_is_not_read_as_a_keysym_name
    assert_equal("less", Clavier::Keysyms.of("<"))
    assert_equal("<", @layout["AC04"].glyph(2))
  end

  def test_letters_get_an_alphabetic_type_so_caps_lock_works
    assert_equal("FOUR_LEVEL_SEMIALPHABETIC", @layout["AD01"].xkb_type)
    assert_equal("FOUR_LEVEL_ALPHABETIC", @layout["AB03"].xkb_type)
    assert_equal("FOUR_LEVEL", @layout["AE04"].xkb_type)
  end

  def test_keysyms_fall_back_to_unicode_names
    assert_equal("agrave", Clavier::Keysyms.of("à"))
    assert_equal("U2264", Clavier::Keysyms.of("≤"))
    assert_equal("dead_circumflex", Clavier::Keysyms.of("<dead_circumflex>"))
    assert_nil(Clavier::Keysyms.of(""))
  end

  def test_the_emitted_symbols_compile
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p("#{dir}/symbols")
      File.write("#{dir}/symbols/#{@layout.name}", Clavier::Xkb.new(@layout).to_s)

      env = { "XKB_CONFIG_EXTRA_PATH" => dir, "XDG_CONFIG_HOME" => "#{dir}/empty" }
      compiled = system(env,
        "xkbcli", "compile-keymap", "--layout", @layout.name, out: File::NULL, err: File::NULL)

      assert(compiled, "xkbcli rejected the generated symbols")
    end
  end
end
