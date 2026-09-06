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

if command -v xkbcli >/dev/null; then
  xkbcli compile-keymap --layout frenchy >/dev/null
  echo "keymap compiles"
fi

echo "installed into $target"

$first_install || exit 0

cat <<'EOF'

Hyprland, in ~/.config/hypr/input.lua:

  hl.config({ input = {
    kb_layout = "frenchy,us",
    kb_options = "compose:caps,shift:both_capslock_cancel,grp:ctrls_toggle,frenchy:digitlock",
  } })

The first three are Omarchy's own, written out because kb_options replaces its value rather than
adding to it. frenchy:digitlock adds the digit lock on Shift + Caps Lock, which turns Num Lock off:
the keypad hands back its arrows and the top row takes the digits.

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
