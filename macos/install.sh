#!/usr/bin/env bash
# Installs frenchy-clavier as a macOS keyboard layout, one file per hardware shape.
set -euo pipefail

source="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target="$HOME/Library/Keyboard Layouts"

first_install=true
[[ -e "$target/frenchy-iso.keylayout" ]] && first_install=false

mkdir -p "$target"
cp "$source"/frenchy-*.keylayout "$target/"

echo "installed into $target"

$first_install || exit 0

cat <<'EOF'

Log out and back in, then add the layout: System Settings > Keyboard > Input Sources > Edit > +,
under Others. Pick "frenchy-clavier (AZERTY) ISO" on a French MacBook or an ISO keyboard,
"frenchy-clavier (AZERTY) ANSI" on a US one.

Option (⌥) plays AltGr and takes over Apple's own Option characters. Caps Lock is Caps Lock:
neither Compose nor the digit lock exists here, see macos/README.md.
EOF
