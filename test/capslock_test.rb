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

      yield Keyboard.new(dir, layout: @layout.name, variant: "ansi", options: "", omarchy: false), "installed alone"
    end
  end

  def test_caps_lock_locks_the_capitals_on_every_group
    each_group do |board, where|
      board.type("CAPS")

      assert(board.caps_locked?, "Caps Lock has to lock on #{where}")
      assert_match(/\p{Upper}/, board.character("AD01"), "#{where} locks without capitalising")

      board.type("CAPS")

      refute(board.caps_locked?, "and unlock on #{where}")
    end
  end

  def test_shift_and_caps_open_a_compose_sequence_on_every_group
    each_group do |board, where|
      board.press("LFSH").press("CAPS")

      assert(board.composing?, "no Compose on #{where}")
    end
  end

  def test_composing_leaves_caps_lock_alone
    each_group do |board, where|
      board.type("LFSH", "CAPS")

      refute(board.caps_locked?, "#{where}: the Shift level must not inherit the Lock of Caps_Lock")
    end
  end

  def test_both_shifts_lock_nothing
    each_group do |board, where|
      board.type("LFSH", "RTSH")

      refute(board.caps_locked?, "#{where}: both Shifts left Caps Lock to its own key")
    end
  end

  def test_altgr_and_caps_hand_the_digit_row_over_and_take_it_back
    on_frenchy do |board, where|
      assert_equal("à", board.character("AE01"), "#{where} does not start on the accents")

      board.type("RALT", "CAPS")

      assert_equal("1", board.character("AE01"), "AltGr+Caps has to lock the digits on #{where}")

      board.type("RALT", "CAPS")

      assert_equal("à", board.character("AE01"), "and hand the accents back on #{where}")
    end
  end

  def test_the_locked_digit_row_keeps_the_accents_one_shift_away
    on_frenchy do |board, where|
      board.type("RALT", "CAPS").press("LFSH")

      assert_equal("à", board.character("AE01"), "#{where}: Shift has to reach back to the accent")
    end
  end

  def test_the_digit_lock_is_the_num_lock_light_going_out
    on_frenchy do |board, where|
      refute(board.digits_locked?, "#{where} starts on Num Lock, the way a session does")

      board.type("RALT", "CAPS")

      assert(board.digits_locked?, "#{where}: the light is the whole indicator, nothing polls")
    end
  end

  def test_caps_lock_capitalises_letters_and_nothing_else
    on_frenchy do |board, where|
      board.type("CAPS")

      assert_equal("À", board.character("AE01"), "#{where}: an accent is a letter")
      assert_equal(",", board.character("AB09"), "#{where}: the lock stops at the letters")
      assert_equal("'", board.character("AC11"), "#{where}: the lock stops at the letters")
    end
  end

  def test_installed_alone_the_layout_carries_caps_lock_compose_and_the_digit_lock
    alone do |board, where|
      board.type("CAPS")

      assert(board.caps_locked?, "#{where}: Caps Lock needs no option")

      board.type("CAPS").press("LFSH").press("CAPS")

      assert(board.composing?, "#{where}: Compose needs no option either")

      board.release("CAPS").release("LFSH").type("RALT", "CAPS")

      assert_equal("1", board.character("AE01"), "#{where}: nor does the digit lock")
    end
  end

  # Omarchy's option rewrites the Caps key of group 1 on two levels, which is why ours exists.
  def test_omarchys_option_alone_drops_the_digit_lock_and_ours_puts_it_back
    each_order(:frenchy, options: Keyboard::OMARCHY_OPTIONS) do |board, where|
      next unless where.end_with?("frenchy first")

      board.type("RALT", "CAPS")

      refute(board.digits_locked?, "#{where}: Omarchy's option is loaded and has the last word")
    end

    on_frenchy do |board, where|
      board.type("RALT", "CAPS")

      assert(board.digits_locked?, "#{where}: frenchy:digitlock comes after it")
    end
  end
end
