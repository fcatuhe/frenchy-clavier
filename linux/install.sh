#!/usr/bin/env bash
# Installs Frenchy-Clavier for any Wayland compositor or X session using libxkbcommon.
set -euo pipefail

source="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/xkb"
target="${XDG_CONFIG_HOME:-$HOME/.config}/xkb"

mkdir -p "$target"
cp -r "$source/." "$target/"

if command -v xkbcli >/dev/null; then
  xkbcli compile-keymap --layout frenchy >/dev/null
  echo "keymap compiles"
fi

cat <<'EOF'
Installed into ~/.config/xkb

Hyprland, in ~/.config/hypr/input.lua:

  hl.config({ input = {
    kb_layout = "us,frenchy",
    kb_options = "frenchy:capslock,grp:ctrls_toggle",
  } })

Both Ctrls switch layouts, in either order. frenchy:capslock replaces Omarchy's compose:caps and
shift:both_capslock_cancel, and adds the digit lock on Shift+Caps to the frenchy group.

No variant means ISO. On an ANSI keyboard add kb_variant = ",ansi", one per layout.

Anything else running X:

  setxkbmap frenchy
EOF
