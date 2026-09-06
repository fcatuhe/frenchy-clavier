require "minitest/autorun"
require_relative "../lib/clavier"

class AzertyTest < Minitest::Test
  def setup
    @layout = Clavier::Layout.load(File.expand_path("../layout.yml", __dir__))
    @iso = Clavier::Boards["framework-13-iso"]
  end

  def test_no_letter_moves_from_azerty
    letters = @layout.each_key.select { |_, key| key.levels[0].match?(/\A[a-z]\z/) }

    assert_equal(26, letters.size)
    letters.each { |code, key| assert(Clavier::Azerty.same?(code, key), "#{code} moved #{key.levels[0]}") }
  end

  def test_the_digit_row_and_the_punctuation_row_are_what_changes
    changed = @layout.each_key.reject { |code, key| Clavier::Azerty.same?(code, key) }.map(&:first)

    assert_equal(%w[TLDE AE01 AE02 AE03 AE04 AE05 AE06 AE07 AE08 AE09 AE10 AE11 AE12
                    AD11 AD12 BKSL AC11 AB07 AB08 AB09 AB10 CAPS], changed)
  end

  def test_the_iso_keys_change_too
    iso = @layout.on(@iso)

    refute(Clavier::Azerty.same?("LSGT", iso["LSGT"]))
    refute(Clavier::Azerty.same?("BKSL", iso["BKSL"]))
  end

  def test_a_key_azerty_does_not_print_on_counts_as_unchanged
    assert(Clavier::Azerty.same?("LFSH", @layout["LFSH"]))
    assert(Clavier::Azerty.same?("SPCE", @layout["SPCE"]))
  end
end
