require "fiddle/import"
require "fileutils"
require_relative "../lib/clavier"

module Xkb
  extend Fiddle::Importer
  dlload "libxkbcommon.so.0"

  NO_DEFAULT_INCLUDES = 1
  TEXT_V1 = 1
  MODS_LOCKED = 1 << 3
  COMPOSING = 1
  CANCELLED = 3
  UP = 0
  DOWN = 1

  extern "void *xkb_context_new(int)"
  extern "int xkb_context_include_path_append(void *, char *)"
  extern "int xkb_context_include_path_append_default(void *)"
  extern "void *xkb_keymap_new_from_names(void *, void *, int)"
  extern "unsigned int xkb_keymap_key_by_name(void *, char *)"
  extern "void *xkb_state_new(void *)"
  extern "unsigned int xkb_state_update_key(void *, unsigned int, int)"
  extern "unsigned int xkb_state_update_mask(void *, unsigned int, unsigned int, unsigned int, unsigned int, unsigned int, unsigned int)"
  extern "unsigned int xkb_state_key_get_one_sym(void *, unsigned int)"
  extern "int xkb_state_mod_name_is_active(void *, char *, int)"
  extern "void *xkb_compose_table_new_from_buffer(void *, char *, size_t, char *, int, int)"
  extern "void *xkb_compose_state_new(void *, int)"
  extern "int xkb_compose_state_feed(void *, unsigned int)"
  extern "int xkb_compose_state_get_status(void *)"
end

class Keyboard
  OMARCHY_OPTIONS = "compose:caps,shift:both_capslock_cancel".freeze
  OPTIONS = "compose:caps,#{Clavier::Xkb::SHIFTLOCK_OPTION}".freeze
  SEQUENCE = %(<Multi_key> <a> <a> : "\u0101"\n).freeze

  def self.install(dir, layout)
    xkb = Clavier::Xkb.new(layout)
    { "symbols/#{layout.name}" => xkb.symbols, "types/#{layout.name}" => xkb.types,
      "compat/#{layout.name}" => xkb.compat, "rules/evdev" => xkb.rules }.each do |path, content|
      target = File.join(dir, "xkb", path)
      FileUtils.mkdir_p(File.dirname(target))
      File.write(target, content)
    end
    dir
  end

  def initialize(dir, layout:, variant:, options:, group: 0)
    @context = Xkb.xkb_context_new(Xkb::NO_DEFAULT_INCLUDES)
    Xkb.xkb_context_include_path_append(@context, File.join(dir, "xkb"))
    Xkb.xkb_context_include_path_append_default(@context)
    @keymap = Xkb.xkb_keymap_new_from_names(@context, names(layout, variant, options), 0)
    raise "the layout does not compile" if @keymap.null?

    @state = Xkb.xkb_state_new(@keymap)
    Xkb.xkb_state_update_mask(@state, 0, 0, 0, 0, 0, group)
    @compose = compose_state
  end

  def type(*codes)
    codes.each { press(it) }
    codes.reverse_each { release(it) }
    self
  end

  def press(code)
    Xkb.xkb_compose_state_feed(@compose, keysym(code))
    Xkb.xkb_state_update_key(@state, keycode(code), Xkb::DOWN)
    self
  end

  def release(code)
    Xkb.xkb_state_update_key(@state, keycode(code), Xkb::UP)
    self
  end

  def keysym(code)
    Xkb.xkb_state_key_get_one_sym(@state, keycode(code))
  end

  def caps_locked?
    Xkb.xkb_state_mod_name_is_active(@state, "Lock", Xkb::MODS_LOCKED) == 1
  end

  def composing? = compose_status == Xkb::COMPOSING

  def compose_cancelled? = compose_status == Xkb::CANCELLED

  private

  def compose_status = Xkb.xkb_compose_state_get_status(@compose)

  def keycode(code) = Xkb.xkb_keymap_key_by_name(@keymap, code)

  def names(layout, variant, options)
    @strings = ["evdev", "pc105", layout, variant, options].map { Fiddle::Pointer[it] }
    @names = @strings.map(&:to_i).pack("Q*")
    Fiddle::Pointer[@names]
  end

  def compose_state
    table = Xkb.xkb_compose_table_new_from_buffer(@context, SEQUENCE, SEQUENCE.bytesize,
      "en_US.UTF-8", Xkb::TEXT_V1, 0)
    raise "the Compose table does not compile" if table.null?

    Xkb.xkb_compose_state_new(table, 0)
  end
end
