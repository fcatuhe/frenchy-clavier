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
    assert_equal("FOUR_LEVEL_SEMIALPHABETIC", @layout["AD02"].xkb_type)
    assert_equal("FOUR_LEVEL_ALPHABETIC", @layout["AB03"].xkb_type)
    assert_equal("FOUR_LEVEL", @layout["AE11"].xkb_type)
  end

  def test_only_the_ten_digit_keys_lock_on_their_shift_level
    lockable = @layout.each_key.filter_map { |code, key| code if key.xkb_type == "FOUR_LEVEL_LOCKABLE_LEVEL2" }

    assert_equal((1..10).map { format("AE%02d", it) }, lockable)
  end

  def test_keysyms_fall_back_to_unicode_names
    assert_equal("agrave", Clavier::Keysyms.of("à"))
    assert_equal("U2264", Clavier::Keysyms.of("≤"))
    assert_equal("dead_circumflex", Clavier::Keysyms.of("<dead_circumflex>"))
    assert_nil(Clavier::Keysyms.of(""))
  end

  def test_the_emitted_files_compile_and_light_the_caps_led_on_the_digit_lock
    Dir.mktmpdir do |dir|
      xkb = Clavier::Xkb.new(@layout)
      { "symbols" => xkb.symbols, "compat" => xkb.compat, "rules/evdev" => xkb.rules }.each do |path, content|
        name = path.include?("/") ? path : "#{path}/#{@layout.name}"
        FileUtils.mkdir_p("#{dir}/xkb/#{File.dirname(name)}")
        File.write("#{dir}/xkb/#{name}", content)
      end

      keymap = IO.popen({ "XDG_CONFIG_HOME" => dir },
        ["xkbcli", "compile-keymap", "--layout", @layout.name, err: File::NULL], &:read)

      assert_includes(keymap, "FOUR_LEVEL_LOCKABLE_LEVEL2")
      assert_match(/indicator "Caps Lock" \{[^}]*modifiers= Lock\+LevelFive/m, keymap)
    end
  end

  def test_the_iso_variant_doubles_enter_and_moves_the_backslash_left
    iso = Clavier::Xkb.new(@layout).iso

    assert_match(/replace key <BKSL> \{[^}]*Return/, iso)
    assert_match(/replace key <LSGT> \{[^}]*backslash, bar/, iso)
  end
end
