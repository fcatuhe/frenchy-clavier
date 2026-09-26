require "minitest/autorun"
require_relative "../lib/clavier"

class ReferenceTest < Minitest::Test
  def setup
    @layout = Clavier::Layout.load(File.expand_path("../layout.yml", __dir__))
    @iso = Clavier::Boards["framework-13-iso"]
  end

  def test_no_letter_moves_from_azerty
    letters = @layout.each_key.select { |_, key| key.levels[0].match?(/\A[a-z]\z/) }

    assert_equal(26, letters.size)
    letters.each { |code, key| assert(Clavier::Reference.typed_as_on_azerty?(code, key, 0), "#{code} moved #{key.levels[0]}") }
  end

  def test_the_digit_row_the_punctuation_row_and_the_locks_are_what_changes_without_altgr
    changed = @layout.each_key.reject { |code, key| [0, 1].all? { Clavier::Reference.typed_as_on_azerty?(code, key, it) } }.map(&:first)

    assert_equal(%w[TLDE AE01 AE02 AE03 AE04 AE05 AE06 AE07 AE08 AE09 AE10 AE11 AE12
                    AD11 AD12 BKSL AC11 AB07 AB08 AB09 AB10 CAPS LFSH RTSH], changed)
  end

  def test_the_keys_nothing_changes_on
    unchanged = @layout.each_key.select { |code, key| Clavier::Reference.same_as_azerty?(code, key) }.map(&:first)

    assert_equal(%w[AD02 AD03 AD06 AD08 AD10 AC01 AC03 AC06 AC07 AC08 AC09 AB01 AB02 AB06], unchanged)
  end

  # The comma kept its AZERTY key when its Shift level changed, and the page showed it as new.
  def test_a_glyph_left_where_azerty_has_it_is_unchanged_whatever_its_neighbours
    assert(Clavier::Reference.typed_as_on_azerty?("AB07", @layout["AB07"], 0))
    refute(Clavier::Reference.typed_as_on_azerty?("AB07", @layout["AB07"], 1))
    assert(Clavier::Reference.typed_as_on_azerty?("AD03", @layout["AD03"], 2), "€ is AltGr+E on AZERTY too")
    refute(Clavier::Reference.typed_as_on_azerty?("AD01", @layout["AD01"], 2), "AZERTY prints no æ")
  end

  def test_a_digit_is_where_azerty_has_it_only_while_the_digit_lock_is_on
    assert(Clavier::Reference.typed_as_on_azerty?("AE01", @layout["AE01"], 1))
    refute(Clavier::Reference.typed_as_on_azerty?("AE01", @layout["AE01"], 1, digits: true))
    assert(Clavier::Reference.typed_as_on_azerty?("AD03", @layout["AD03"], 0, digits: true), "the lock leaves the letters alone")
  end

  def test_the_iso_keys_change_too
    iso = @layout.on(@iso)

    refute(Clavier::Reference.same_as_azerty?("LSGT", iso["LSGT"]))
    refute(Clavier::Reference.same_as_azerty?("BKSL", iso["BKSL"]))
  end

  def test_every_reference_layout_fills_every_key_of_its_hardware
    thinkpad = Clavier::Boards["x1-carbon-ansi"]
    macbook = Clavier::Boards["macbook-fr"]

    assert_empty(@iso.codes - Clavier::Reference.keys(Clavier::Reference::AZERTY).keys)
    assert_empty(thinkpad.codes - Clavier::Reference.keys(Clavier::Reference::QWERTY_US).keys)
    assert_empty(macbook.codes - Clavier::Reference.keys(Clavier::Reference::AZERTY_MAC).keys)
  end

  def test_the_mac_azerty_is_apple_s_french_not_the_pc_one
    mac = Clavier::Reference::AZERTY_MAC

    assert_equal(["@", "#"], mac.fetch("TLDE").first(2))
    assert_equal(["§", "6"], mac.fetch("AE06").first(2))
    assert_equal(["`", "£", "@"], mac.fetch("BKSL"))
    assert_equal(["=", "+"], mac.fetch("AB10").first(2))
    assert_equal("‡", mac.fetch("AC01")[2], "Option+Q is the double dagger on a Mac, xkeyboard-config gets it wrong")
  end

  def test_the_mac_board_wears_apple_s_caps
    keys = Clavier::Reference.keys(Clavier::Reference::AZERTY_MAC)
    labels = Clavier::Boards["macbook-fr"].rows.flatten.filter_map(&:label)

    assert_equal("\u21EA", keys.fetch("CAPS").glyph(0))
    assert_equal("\u21E7", keys.fetch("LFSH").glyph(0))
    assert_includes(labels, "\u232B")
    assert_includes(labels, "\u23CE")
    assert_includes(labels, "cmd")
    refute_includes(labels, "command")
  end

  def test_fn_sits_left_of_ctrl_on_every_pc_board
    Clavier::Boards.all.reject { it.hardware == "Apple" }.each do |board|
      labels = board.rows.last.filter_map(&:label)

      assert_equal(%w[Fn Ctrl], labels.first(2), board.id)
    end
  end

  def test_a_reference_key_draws_like_a_layout_key
    keys = Clavier::Reference.keys(Clavier::Reference::AZERTY)

    assert_equal("é", keys.fetch("AE02").glyph(0))
    assert_equal("~", keys.fetch("AE02").glyph(2))
    assert(keys.fetch("AD11").dead?(0))
    assert_equal("", keys.fetch("AE02").glyph(3))
  end

  def test_a_modifier_azerty_does_not_print_is_compared_to_what_it_types
    assert(Clavier::Reference.typed_as_on_azerty?("LFSH", @layout["LFSH"], 0))
    refute(Clavier::Reference.typed_as_on_azerty?("LFSH", @layout["LFSH"], 1), "Maj + Maj locks the capitals, AZERTY's does not")
    assert(Clavier::Reference.typed_as_on_azerty?("SPCE", @layout["SPCE"], 1))
    refute(Clavier::Reference.typed_as_on_azerty?("SPCE", @layout["SPCE"], 2), "AltGr + Espace is the new nbsp")
  end
end
