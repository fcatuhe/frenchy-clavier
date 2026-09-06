require "minitest/autorun"
require "json"
require_relative "../lib/clavier"

class KeymapTest < Minitest::Test
  def setup
    root = File.expand_path("..", __dir__)
    @layout = Clavier::Layout.load(File.join(root, "layout.yml"))
    @keymap = Clavier::Keymap.new(@layout, compose_path: File.join(root, "compose.yml"))
    @keys = JSON.parse(@keymap.to_json).fetch("keys")
  end

  def test_the_browser_reads_keys_by_position_not_by_letter
    assert_equal(["a", "A", "æ", "Æ"], @keys.fetch("KeyQ"))
    assert_equal(["à", "1", "§", "À"], @keys.fetch("Digit1"))
  end

  def test_both_shapes_reach_the_hash_from_the_key_their_hardware_has
    assert_equal(["#", "\\"], @keys.fetch("Backslash").first(2))
    assert_equal(["#", "\\"], @keys.fetch("IntlBackslash").first(2))
  end

  def test_a_free_level_is_null_and_a_modifier_is_never_typed
    assert_nil(@keys.fetch("KeyW")[2])
    assert_equal([nil] * 4, @keys.fetch("CapsLock"))
  end

  def test_a_dead_level_announces_itself_so_the_next_stroke_can_resolve_it
    circumflex = @keys.fetch("Digit8").first

    assert_equal("dead_circumflex", circumflex.fetch("d"))
    assert_equal("â", JSON.parse(@keymap.to_json).dig("dead", "dead_circumflex", "a"))
  end

  def test_the_spaces_survive_being_named_keysyms
    assert_equal([" ", " ", "\u00A0", "\u202F"], @keys.fetch("Space"))
  end

  def test_every_curated_compose_sequence_reaches_the_browser
    compose = JSON.parse(@keymap.to_json).fetch("compose")

    assert_equal("°", compose.fetch("oo"))
    assert_equal("→", compose.fetch("->"))
    assert_equal("½", compose.fetch("12"))
  end
end
