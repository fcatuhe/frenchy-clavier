require "minitest/autorun"
require "tmpdir"
require_relative "keyboard"

class CapslockTest < Minitest::Test
  ORDERS = {
    "frenchy first" => { layout: "frenchy,us", variant: "ansi,", frenchy: 0 },
    "QWERTY first" => { layout: "us,frenchy", variant: ",ansi", frenchy: 1 }
  }.freeze

  def setup
    @layout = Clavier::Layout.load(File.expand_path("../layout.yml", __dir__))
    @option = Clavier::Xkb.new(@layout).option
  end

  def on_frenchy(&) = each_order(:frenchy, &)

  def on_qwerty(&) = each_order(:qwerty, &)

  def each_group(&)
    on_frenchy(&)
    on_qwerty(&)
  end

  def each_order(group, options: @option)
    Dir.mktmpdir do |dir|
      Keyboard.install(dir, @layout)

      ORDERS.each do |name, order|
        index = group == :frenchy ? order[:frenchy] : 1 - order[:frenchy]
        yield Keyboard.new(dir, layout: order[:layout], variant: order[:variant],
          options: options, group: index), "#{group}, #{name}"
      end
    end
  end

  def test_the_compose_key_opens_a_sequence_on_every_group
    each_group { |board, where| assert(board.press("CAPS").composing?, "no Compose on #{where}") }
  end

  def test_both_shifts_lock_caps
    each_group do |board, where|
      board.press("LFSH").press("RTSH")

      assert(board.caps_locked?, "the second Shift has to lock Caps on #{where}")
    end
  end

  def test_a_locked_keyboard_spends_the_next_shift_on_the_lock_the_way_omarchy_does
    each_group do |board, where|
      board.type("LFSH", "RTSH").press("LFSH")

      assert_match(/\p{Upper}/, board.character("AD01"),
        "#{where}: while locked the Shift key unlocks, it does not shift")

      board.release("LFSH")

      refute(board.caps_locked?, "#{where}: one Shift has to hand the keyboard back")
    end
  end

  def test_a_locked_keyboard_types_capitals_on_every_group
    each_group do |board, where|
      board.type("LFSH", "RTSH")

      assert_match(/\p{Upper}/, board.character("AD01"), "#{where} locks without capitalising")
    end
  end

  def test_both_shifts_again_hand_the_keyboard_back
    each_group do |board, where|
      board.type("LFSH", "RTSH").type("LFSH", "RTSH")

      refute(board.caps_locked?, "the same pair has to unlock on #{where}")
    end
  end

  # A Shift key whose type reads Lock resolves one level on press, another on release.
  def test_unlocking_leaves_no_modifier_stuck_behind
    each_group do |board, where|
      board.type("LFSH", "RTSH").type("LFSH", "RTSH")

      assert_match(/\p{Lower}/, board.character("AD01"), "#{where}: something stayed down")
    end
  end


  def test_shift_and_caps_lock_the_digit_row_whichever_group_frenchy_sits_in
    on_frenchy do |board, where|
      assert_equal("à", board.character("AE01"), "#{where} does not start on the accents")

      board.type("LFSH", "CAPS")

      assert_equal("1", board.character("AE01"), "Shift+Caps has to lock the digits on #{where}")

      board.type("LFSH", "CAPS")

      assert_equal("à", board.character("AE01"), "and hand the accents back on #{where}")
    end
  end


  def test_a_locked_keyboard_capitalises_letters_and_nothing_else
    on_frenchy do |board, where|
      board.type("LFSH", "RTSH")

      assert_equal("À", board.character("AE01"), "#{where}: an accent is a letter")
      assert_equal("'", board.character("AC11"), "#{where}: the lock stops at the letters")
      assert_equal(":", board.character("AB09"), "#{where}: the lock stops at the letters")
    end
  end

  def test_the_qwerty_group_answers_shift_and_caps_with_the_compose_omarchy_gives_it
    on_qwerty do |board, where|
      board.press("LFSH")

      assert_equal("Multi_key", board.keysym_name("CAPS"),
        "#{where}: the digit lock belongs to frenchy, English stays Omarchy's")
    end
  end

  def test_omarchys_shift_option_spends_the_shift_on_the_lock_instead_of_shifting
    each_order(:qwerty, options: Keyboard::OMARCHY_OPTIONS) do |board, where|
      board.type("LFSH", "RTSH").press("LFSH")

      assert_match(/\p{Upper}/, board.character("AD01"),
        "#{where}: its Shift key answers Caps_Lock while locked, so it cannot shift")
    end
  end
end
