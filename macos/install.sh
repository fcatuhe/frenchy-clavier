#!/usr/bin/env bash
# Installs Frenchy-Clavier as a macOS keyboard layout, one file per hardware shape.
set -euo pipefail

source="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target="$HOME/Library/Keyboard Layouts"

mkdir -p "$target"
cp "$source"/frenchy-*.keylayout "$target/"

cat <<'EOF'
Installed into ~/Library/Keyboard Layouts

Log out and back in, then add the layout: System Settings > Keyboard > Input Sources > Edit > +,
under Others. Pick "frenchy-clavier (AZERTY), ISO" on a French MacBook or an ISO keyboard,
"frenchy-clavier (AZERTY), ANSI" on a US one.

Option (⌥) plays AltGr and takes over Apple's own Option characters. Caps Lock is Caps Lock:
neither Compose nor the digit lock exists here, see macos/README.md.
EOF
