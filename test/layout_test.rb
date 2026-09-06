require "minitest/autorun"
require "tmpdir"
require_relative "keyboard"

class LayoutTest < Minitest::Test
  def setup
    @layout = Clavier::Layout.load(File.expand_path("../layout.yml", __dir__))
  end

  def test_the_base_layout_asks_for_no_key_ansi_hardware_lacks
    assert_nil(@layout["LSGT"], "LSGT belongs to the iso section, ANSI hardware has no such key")
  end

  def test_every_ascii_printable_is_reachable
    printable = (33..126).map(&:chr)

    (printable - @layout.characters.to_a).then { assert_empty(it, "unreachable: #{it.join}") }
  end

  def test_a_literal_angle_bracket_is_not_read_as_a_keysym_name
    assert_equal("less", Clavier::Keysyms.of("<"))
    assert_equal("<", @layout["AC04"].glyph(2))
  end

  def test_the_digit_lock_type_is_ours_so_an_older_xkeyboard_config_still_compiles
    refute_match(/FOUR_LEVEL_LOCKABLE_LEVEL2/, Clavier::Xkb.new(@layout).symbols,
      "the stock type only exists from xkeyboard-config 2.42, Ubuntu 24.04 ships 2.41")
    assert_match(/map\[Shift\] = Level1;/, Clavier::Xkb.new(@layout).types,
      "Shift on a locked row has to hand back the base level, that is where the accents live")
  end

  def test_letters_get_an_alphabetic_type_so_caps_lock_works
    assert_equal("FOUR_LEVEL_SEMIALPHABETIC", @layout["AD02"].xkb_type)
    assert_equal("FOUR_LEVEL_ALPHABETIC", @layout["AB03"].xkb_type)
    assert_equal("FOUR_LEVEL", @layout["AE11"].xkb_type)
  end

  def test_only_the_ten_digit_keys_lock_on_their_shift_level
    lockable = @layout.each_key.filter_map { |code, key| code if key.xkb_type == Clavier::Xkb::DIGITS_LOCK }

    assert_equal((1..10).map { format("AE%02d", it) }, lockable)
  end

  def test_keysyms_fall_back_to_unicode_names
    assert_equal("agrave", Clavier::Keysyms.of("à"))
    assert_equal("U2264", Clavier::Keysyms.of("≤"))
    assert_equal("dead_circumflex", Clavier::Keysyms.of("<dead_circumflex>"))
    assert_nil(Clavier::Keysyms.of(""))
  end

  def install(dir) = Keyboard.install(dir, @layout)

  def test_the_emitted_files_compile_and_the_digit_lock_rides_the_num_lock_modifier
    Dir.mktmpdir do |dir|
      install(dir)

      keymap = IO.popen({ "XDG_CONFIG_HOME" => dir },
        ["xkbcli", "compile-keymap", "--layout", @layout.name, err: File::NULL], &:read)

      assert_includes(keymap, Clavier::Xkb::DIGITS_LOCK)
      assert_match(/interpret ISO_Level5_Lock[^}]*LockMods\(modifiers=NumLock\)/m, keymap,
        "upstream level5(level5_lock) is what puts the lock on a modifier with a light")
      refute_match(/indicator[^}]*modifiers= LevelFive/m, keymap,
        "no light of our own to drive, the Num Lock one already says it")
    end
  end

  def test_the_option_carries_the_digit_lock_alone_and_reaches_every_group
    rules = Clavier::Xkb.new(@layout).rules

    refute_match(/compose\(caps\)|shiftlock/, rules, "Compose and Caps Lock are Omarchy's own options")

    (1..Clavier::Xkb::GROUPS).each do |group|
      assert_match(/^  \* #{@layout.name}:digitlock = \+#{@layout.name}\(digitlock\):#{group}$/, rules,
        "group #{group} has to reach the lock, wherever frenchy sits")
    end
  end

  def test_the_shift_keys_lock_without_joining_the_lock_modifier_map
    Dir.mktmpdir do |dir|
      install(dir)

      keymap = IO.popen({ "XDG_CONFIG_HOME" => dir },
        ["xkbcli", "compile-keymap", "--layout", "us,#{@layout.name}", "--options", "caps:none", err: File::NULL], &:read)

      refute_match(/modifier_map Lock/, keymap, "a Lock modmap follows the key across every group")
      assert_match(/LockMods\(modifiers=Lock\)/, keymap)
    end
  end

  def test_a_layout_description_carries_no_comma_for_a_bar_widget_to_cut_itself_on
    xkb = Clavier::Xkb.new(@layout)

    [xkb.symbols, xkb.registry].each do |emitted|
      emitted.scan(/name\[Group1\] = "([^"]+)"|<description>([^<]+)<\/description>/).flatten.compact
        .reject { it == Clavier::Xkb::OPTION_DESCRIPTION }
        .each { refute_includes(it, ",", "Hyprland's activelayout event is comma-separated") }
    end
  end

  def test_the_groups_switch_on_the_ctrls_because_both_alts_would_eat_the_altgr
    Dir.mktmpdir do |dir|
      install(dir)

      { Keyboard::GROUP_TOGGLE => "{", "grp:alts_toggle" => "(" }.each do |toggle, brace|
        board = Keyboard.new(dir, layout: "#{@layout.name},us", variant: "ansi,",
          options: "#{Keyboard::OMARCHY_OPTIONS},#{toggle}")

        assert_equal(brace, board.press("RALT").character("AE04"),
          "#{toggle} decides whether the right thumb still reaches the third level")
      end
    end
  end

  def test_a_layout_picker_can_find_the_option_the_installer_asks_for
    Dir.mktmpdir do |dir|
      install(dir)

      registry = IO.popen({ "XDG_CONFIG_HOME" => dir }, ["xkbcli", "list", err: File::NULL], &:read)

      assert_includes(registry, Clavier::Xkb.new(@layout).option)
      assert_includes(registry, Clavier::Xkb::OPTION_DESCRIPTION)
    end
  end

  def test_the_iso_variant_doubles_enter_and_moves_the_hash_key_left
    iso = Clavier::Xkb.new(@layout).iso

    assert_match(/replace key <BKSL> \{[^}]*Return/, iso)
    assert_match(/replace key <LSGT> \{[^}]*numbersign\s*, backslash/, iso)
  end
end
