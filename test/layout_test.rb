require "minitest/autorun"
require "tmpdir"
require "fileutils"
require_relative "../lib/clavier"

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
    assert_match(/map\[Shift\+LevelFive\] = Level1;/, Clavier::Xkb.new(@layout).types,
      "Shift while locked has to hand back the base level, that is where the quotes live")
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

  def install(dir)
    xkb = Clavier::Xkb.new(@layout)
    { "symbols" => xkb.symbols, "types" => xkb.types, "compat" => xkb.compat,
      "rules/evdev" => xkb.rules }.each do |path, content|
      name = path.include?("/") ? path : "#{path}/#{@layout.name}"
      FileUtils.mkdir_p("#{dir}/xkb/#{File.dirname(name)}")
      File.write("#{dir}/xkb/#{name}", content)
    end
  end

  def test_the_emitted_files_compile_and_the_digit_lock_drives_its_own_indicator
    Dir.mktmpdir do |dir|
      install(dir)

      keymap = IO.popen({ "XDG_CONFIG_HOME" => dir },
        ["xkbcli", "compile-keymap", "--layout", @layout.name, err: File::NULL], &:read)

      assert_includes(keymap, Clavier::Xkb::DIGITS_LOCK)
      assert_match(/indicator "Scroll Lock" \{[^}]*modifiers= LevelFive/m, keymap)
      refute_match(/indicator "Caps Lock" \{[^}]*LevelFive/m, keymap,
        "Caps Lock has to mean Caps Lock, or one light says two things")
    end
  end

  def test_omarchys_own_options_leave_the_digit_lock_alone
    Dir.mktmpdir do |dir|
      install(dir)

      keymap = IO.popen({ "XDG_CONFIG_HOME" => dir },
        ["xkbcli", "compile-keymap", "--layout", "us,#{@layout.name}", "--variant", ",ansi",
         "--options", "compose:caps,shift:both_capslock_cancel", err: File::NULL], &:read)

      assert_match(/key <CAPS>[^}]*symbols\[2\]= \[\s*Multi_key,\s*ISO_Level5_Lock/m, keymap,
        "compose:caps must not take the digit lock off Shift+Caps")
      assert_match(/key <CAPS>[^}]*symbols\[1\]= \[\s*Multi_key,\s*Multi_key/m, keymap,
        "the QWERTY group keeps the Compose that Omarchy gives it")
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

  def test_the_iso_variant_doubles_enter_and_moves_the_backslash_left
    iso = Clavier::Xkb.new(@layout).iso

    assert_match(/replace key <BKSL> \{[^}]*Return/, iso)
    assert_match(/replace key <LSGT> \{[^}]*backslash\s*, bar/, iso)
  end
end
