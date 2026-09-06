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
    @options = "#{Keyboard::OMARCHY_OPTIONS},#{Keyboard::GROUP_TOGGLE},#{Clavier::Xkb.new(@layout).option}"
  end

  def on_frenchy(&) = each_order(:frenchy, &)

  def on_qwerty(&) = each_order(:qwerty, &)

  def each_group(&)
    on_frenchy(&)
    on_qwerty(&)
  end

  def each_order(group, options: @options)
    Dir.mktmpdir do |dir|
      Keyboard.install(dir, @layout)

      ORDERS.each do |name, order|
        index = group == :frenchy ? order[:frenchy] : 1 - order[:frenchy]
        yield Keyboard.new(dir, layout: order[:layout], variant: order[:variant],
          options: options, group: index), "#{group}, #{name}"
      end
    end
  end

  def alone(&)
    Dir.mktmpdir do |dir|
      Keyboard.install(dir, @layout)

      yield Keyboard.new(dir, layout: @layout.name, variant: "ansi", options: ""), "installed alone"
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

  def test_a_locked_keyboard_spends_the_next_shift_on_the_lock
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

  def test_shift_and_caps_hand_the_digit_row_over_and_take_it_back
    on_frenchy do |board, where|
      assert_equal("à", board.character("AE01"), "#{where} does not start on the accents")

      board.type("LFSH", "CAPS")

      assert_equal("1", board.character("AE01"), "Shift+Caps has to lock the digits on #{where}")

      board.type("LFSH", "CAPS")

      assert_equal("à", board.character("AE01"), "and hand the accents back on #{where}")
    end
  end

  def test_the_locked_digit_row_keeps_the_accents_one_shift_away
    on_frenchy do |board, where|
      board.type("LFSH", "CAPS").press("LFSH")

      assert_equal("à", board.character("AE01"), "#{where}: Shift has to reach back to the accent")
    end
  end

  def test_the_digit_lock_is_the_num_lock_light_going_out
    on_frenchy do |board, where|
      refute(board.digits_locked?, "#{where} starts on Num Lock, the way a session does")

      board.type("LFSH", "CAPS")

      assert(board.digits_locked?, "#{where}: the light is the whole indicator, nothing polls")
    end
  end

  def test_the_qwerty_group_holds_the_same_lock_because_num_lock_is_one_state
    on_qwerty do |board, where|
      board.press("LFSH")

      assert_equal("ISO_Level5_Lock", board.keysym_name("CAPS"),
        "#{where}: one Num Lock for the keyboard, so the key cannot mean two things")
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

  def test_installed_alone_the_layout_carries_compose_the_caps_lock_and_the_digit_lock
    alone do |board, where|
      assert(board.press("CAPS").composing?, "no Compose on #{where}")

      board.type("LFSH", "RTSH")

      assert(board.caps_locked?, "#{where}: both Shifts lock without any option")

      board.type("LFSH", "RTSH").type("LFSH", "CAPS")

      assert_equal("1", board.character("AE01"), "#{where}: the digit lock needs no option either")
    end
  end

  def test_the_shift_keys_of_a_lone_install_close_an_open_compose_sequence
    alone do |board, where|
      board.type("CAPS").type("LFSH", "RTSH")

      assert(board.compose_cancelled?, "#{where}: VoidSymbol is what Compose cannot ignore")
    end
  end

  def test_omarchys_shift_option_locks_caps_on_a_compose_sequence_it_leaves_open
    each_order(:qwerty, options: Keyboard::OMARCHY_OPTIONS) do |board, where|
      board.type("CAPS").type("LFSH", "RTSH")

      assert(board.caps_locked?, "#{where}: the pair still locks")
      assert(board.composing?, "#{where}: Caps_Lock is a keysym Compose ignores")
    end
  end

  def test_the_shift_keys_of_a_lone_install_stay_out_of_the_lock_modifier_map
    alone do |board, where|
      board.type("LFSH", "RTSH").type("LFSH", "RTSH")

      refute(board.caps_locked?, "#{where}: the same pair has to unlock")
      assert_match(/\p{Lower}/, board.character("AD01"), "#{where}: something stayed down")
    end
  end
end
