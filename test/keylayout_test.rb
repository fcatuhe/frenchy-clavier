require "minitest/autorun"
require "rexml/document"
require "tmpdir"
require_relative "keyboard"

class KeylayoutTest < Minitest::Test
  MAPS = (0...Clavier::Keylayout::MAPS.size).freeze
  LEVELS = (0..3).freeze
  COMBOS = [[], %w[LFSH], %w[RALT], %w[LFSH RALT]].freeze
  LEAKY = "LSGT".freeze

  def setup
    @layout = Clavier::Layout.load(File.expand_path("../layout.yml", __dir__))
    @documents = %w[iso ansi].to_h { [it, REXML::Document.new(Clavier::Keylayout.new(@layout, variant: it).to_s)] }
    @iso = @documents.fetch("iso")
    @ansi = @documents.fetch("ansi")
  end

  def maps(document)
    @maps ||= {}
    @maps[document.object_id] ||= MAPS.map { |index|
      document.elements.to_a("keyboard/keyMapSet/keyMap[@index='#{index}']/key")
        .to_h { |key| [key.attribute("code").value.to_i, key] }
    }
  end

  def typed(document, index, code)
    key = maps(document)[index][code] or return ""
    return key.attribute("output").value unless (id = key.attribute("action")&.value)

    document.elements["keyboard/actions/action[@id='#{id}']/when[@state='none']"]&.attribute("output")&.value.to_s
  end

  def codes(variant)
    variant == "iso" ? Clavier::MacCodes::TABLE.merge(Clavier::MacCodes::ISO) : Clavier::MacCodes::TABLE
  end

  # AltGr on the ISO key answers | on Linux, leaked by pc(pc105), not asked for in layout.yml.
  def test_the_mac_file_types_what_linux_types
    @documents.each do |variant, document|
      Dir.mktmpdir do |dir|
        Keyboard.install(dir, @layout)

        COMBOS.each_with_index do |modifiers, index|
          keyboard = Keyboard.new(dir, layout: @layout.name, variant: variant, options: "")
          modifiers.each { keyboard.press(it) }

          codes(variant).except(LEAKY).each do |code, mac|
            assert_equal(keyboard.character(code), typed(document, index, mac),
              "#{variant} #{code} under #{modifiers.join('+')}")
          end
        end
      end
    end
  end

  def test_every_character_the_layout_reaches_is_typable_on_the_mac_too
    reached = LEVELS.flat_map { |index| maps(@iso)[index].keys.map { typed(@iso, index, it) } }

    missing = @layout.characters.to_a - reached
    assert_empty(missing, "unreachable on macOS: #{missing.join}")
  end

  def test_the_menu_reads_the_name_the_xkb_files_carry
    assert_equal("frenchy-clavier (AZERTY) ISO", @iso.elements["keyboard"].attribute("name").value)
    assert_includes(Clavier::Xkb.new(@layout).symbols, "frenchy-clavier (AZERTY) ISO")
  end

  def test_no_map_asks_one_key_code_to_do_two_things
    MAPS.each do |index|
      codes = @iso.elements.to_a("keyboard/keyMapSet/keyMap[@index='#{index}']/key")
        .map { it.attribute("code").value }

      assert_equal(codes.uniq, codes, "map #{index} repeats a key code")
    end
  end

  def test_apple_iso_hardware_reads_the_top_left_key_as_the_section_key
    assert_equal("@", typed(@iso, 0, Clavier::MacCodes::SECTION))
    assert_equal("#", typed(@iso, 0, Clavier::MacCodes::GRAVE))
    assert_equal("@", typed(@ansi, 0, Clavier::MacCodes::GRAVE))
    assert_equal("", typed(@ansi, 0, Clavier::MacCodes::SECTION), "ANSI hardware has no section key")
  end

  def test_the_iso_key_left_of_return_is_a_second_return_under_every_modifier
    MAPS.each { assert_equal("\r", typed(@iso, it, 42), "map #{it} loses the second Return") }
    assert_equal("#", typed(@ansi, 0, 42))
    assert_equal("\\", typed(@ansi, 1, 42))
  end

  def test_option_carries_the_third_level_because_macos_has_no_altgr
    assert_equal("{", typed(@iso, 2, 21))
    assert_equal("ç", typed(@iso, 2, 8))
    assert_equal("Ç", typed(@iso, 3, 8))
  end

  def test_a_dead_key_enters_its_state_and_the_letters_answer_from_there
    assert_equal("dead_circumflex", maps(@iso)[0].fetch(28).attribute("action").value)

    letter = @iso.elements["keyboard/actions/action[@id='a']"]
    assert_equal("a", letter.elements["when[@state='none']"].attribute("output").value)
    assert_equal("â", letter.elements["when[@state='dead_circumflex']"].attribute("output").value)
  end

  def test_the_base_state_leads_every_action_as_the_format_demands
    @iso.elements.each("keyboard/actions/action") do |action|
      assert_equal("none", action.elements[1].attribute("state").value,
        "#{action.attribute('id').value} answers another state before the base one")
    end
  end

  def test_every_state_a_key_can_enter_knows_how_to_end
    states = @iso.elements.to_a("keyboard/actions/action/when[@next]").map { it.attribute("next").value }
    ended = @iso.elements.to_a("keyboard/terminators/when").map { it.attribute("state").value }

    assert_equal(states.uniq.sort, ended.sort)
    assert_equal("^", @iso.elements["keyboard/terminators/when[@state='dead_circumflex']"].attribute("output").value)
  end

  def test_caps_lock_uppercases_the_letters_and_leaves_the_digit_row_alone
    assert_equal("A", typed(@iso, 4, 12))
    assert_equal("à", typed(@iso, 4, 18))
    assert_equal("(", typed(@iso, 4, 21))
    assert_equal("a", typed(@iso, 5, 12), "Shift undoes the lock, as XKB does")
  end

  def test_caps_lock_reaches_the_accented_capitals_through_option_too
    assert_equal("Ç", typed(@iso, 6, 8))
    assert_equal("ç", typed(@iso, 7, 8))
    assert_equal("{", typed(@iso, 6, 21), "the braces do not care about the lock")
  end

  DTD = "/System/Library/DTDs/KeyboardLayout.dtd".freeze

  def test_the_file_validates_against_the_system_dtd
    skip "no #{DTD} outside macOS" unless File.exist?(DTD)

    Dir.mktmpdir do |dir|
      file = File.join(dir, "frenchy.keylayout")
      File.write(file, Clavier::Keylayout.new(@layout, variant: "iso").to_s)

      assert(system("xmllint", "--noout", "--valid", file), "the DTD refuses the file")
    end
  end
end
