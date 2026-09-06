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
    letters.each { |code, key| assert(Clavier::Reference.same_as_azerty?(code, key), "#{code} moved #{key.levels[0]}") }
  end

  def test_the_digit_row_and_the_punctuation_row_are_what_changes
    changed = @layout.each_key.reject { |code, key| Clavier::Reference.same_as_azerty?(code, key) }.map(&:first)

    assert_equal(%w[TLDE AE01 AE02 AE03 AE04 AE05 AE06 AE07 AE08 AE09 AE10 AE11 AE12
                    AD11 AD12 BKSL AC11 AB07 AB08 AB09 AB10 CAPS], changed)
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

  def test_a_key_azerty_does_not_print_on_counts_as_unchanged
    assert(Clavier::Reference.same_as_azerty?("LFSH", @layout["LFSH"]))
    assert(Clavier::Reference.same_as_azerty?("SPCE", @layout["SPCE"]))
  end
end
