require "minitest/autorun"
require "tmpdir"
require_relative "keyboard"

class ComposeTest < Minitest::Test
  GROUPS = { "QWERTY" => 0, "frenchy" => 1 }.freeze

  def setup
    @layout = Clavier::Layout.load(File.expand_path("../layout.yml", __dir__))
  end

  def keyboard(dir, group:, options: Keyboard::OPTIONS)
    Keyboard.install(dir, @layout)
    Keyboard.new(dir, layout: "us,#{@layout.name}", variant: ",ansi", options: options, group: group)
  end

  def each_group
    Dir.mktmpdir { |dir| GROUPS.each { |name, group| yield keyboard(dir, group: group), name } }
  end

  def test_the_compose_key_opens_a_sequence_on_both_groups
    each_group { |board, name| assert(board.press("CAPS").composing?, "no Compose on #{name}") }
  end

  def test_both_shifts_lock_caps_and_drop_the_pending_compose_sequence
    each_group do |board, name|
      board.type("CAPS").press("LFSH").press("RTSH")

      assert(board.caps_locked?, "the second Shift has to lock Caps on #{name}")
      assert(board.compose_cancelled?,
        "on #{name} a sequence left open swallows everything typed in caps")
    end
  end

  def test_one_shift_alone_unlocks_caps_again
    each_group do |board, name|
      board.type("LFSH", "RTSH").type("LFSH")

      refute(board.caps_locked?, "one Shift has to hand the keyboard back on #{name}")
    end
  end

  def test_omarchys_shift_option_locks_the_qwerty_group_but_leaves_it_composing
    Dir.mktmpdir do |dir|
      board = keyboard(dir, group: GROUPS.fetch("QWERTY"), options: Keyboard::OMARCHY_OPTIONS)
      board.type("CAPS").press("LFSH").press("RTSH")

      assert(board.caps_locked?)
      assert(board.composing?, "Compose ignores the Caps_Lock keysym that option puts there")
    end
  end
end
