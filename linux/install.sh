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
    kb_layout = "frenchy,us",
    kb_options = "shift:both_capslock_cancel,grp:ctrls_toggle",
  } })

Add kb_variant = "iso" on an ISO keyboard. Both Ctrls switch layouts.

Anything else running X:

  setxkbmap frenchy -option shift:both_capslock_cancel
EOF
