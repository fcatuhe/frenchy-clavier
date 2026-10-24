#!/usr/bin/env bash
# Installs frenchy-clavier for any Wayland compositor or X session using libxkbcommon.
set -euo pipefail

source="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/xkb"
target="${XDG_CONFIG_HOME:-$HOME/.config}/xkb"
stamp="$(date +%Y%m%d%H%M%S)"

first_install=true
[[ -e "$target/symbols/frenchy" ]] && first_install=false

ours() {
  [[ $(basename "$1") == frenchy ]] || grep -q frenchy "$1"
}

while IFS= read -r -d '' file; do
  relative="${file#"$source"/}"
  destination="$target/$relative"

  mkdir -p "$(dirname "$destination")"

  if [[ -e $destination ]] && ! ours "$destination"; then
    mv "$destination" "$destination.bak.$stamp"
    echo "kept your $relative as $relative.bak.$stamp"
  fi

  cp "$file" "$destination"
done < <(find "$source" -type f -print0)

if [[ -e $target/rules/evdev ]] && ours "$target/rules/evdev"; then
  rm "$target/rules/evdev"
  echo "removed the rules/evdev of an older install, it hid the system's own rules"
fi

if command -v xkbcli >/dev/null; then
  xkbcli compile-keymap --layout frenchy | grep -q FRENCHY_DIGITS_LOCK ||
    { echo "libxkbcommon ignored rules/evdev.post, it reads those from 1.13" >&2; exit 1; }
  echo "keymap compiles"
fi

echo "installed into $target"

$first_install || exit 0

cat <<'EOF'

Hyprland, in ~/.config/hypr/input.lua:

  hl.config({ input = {
    kb_layout = "frenchy,us",
    kb_options = "omarchy:shift_caps_compose,grp:ctrls_toggle,frenchy:digitlock",
  } })

The first is Omarchy's own, written out because kb_options replaces its value rather than adding
to it: Caps Lock locks the capitals and Shift + Caps Lock is Compose. frenchy:digitlock
adds the digit lock on AltGr + Caps Lock, which turns Num Lock off: the keypad hands back its
arrows and the top row takes the digits. Before Omarchy 4.5, libxkbcommon logs that it does not
know omarchy:shift_caps_compose and skips it, and frenchy:digitlock gives the same Caps key.

Keep frenchy first. Hyprland resolves SUPER + letter bindings against the first layout, and
omarchy system lock switches every keyboard back to it at each lock.

Both Ctrls switch layouts. Omarchy's example switches on both Alts, and grp:alts_toggle takes the
right Alt to do it, which is the AltGr this layout puts its whole third level on.

No variant means ISO. On an ANSI keyboard add kb_variant = "ansi,", one per layout.

The TTY and the disk password prompt read XKBLAYOUT from /etc/vconsole.conf, which this leaves
alone: those two stay on the layout the system was installed with.

Anything else running X:

  setxkbmap frenchy
EOF
