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

  def test_the_mac_azerty_is_the_one_xkeyboard_config_calls_fr_mac
    mac = Clavier::Reference::AZERTY_MAC

    assert_equal(["@", "#"], mac.fetch("TLDE").first(2))
    assert_equal(["<dead_grave>", "£", "@"], mac.fetch("BKSL"))
    assert_equal(["=", "+"], mac.fetch("AB10").first(2))
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
