#!/bin/bash
# Met à jour l'app Transcrire et la commande transcrire, sans tout réinstaller.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

git -C "$SCRIPT_DIR" pull --ff-only
install -m 755 "$SCRIPT_DIR/transcrire" "$(brew --prefix)/bin/transcrire"

if [ -d "$HOME/Applications/Transcrire.app" ] && [ ! -d /Applications/Transcrire.app ]; then
  APP="$HOME/Applications/Transcrire.app"
else
  APP="/Applications/Transcrire.app"
fi
rm -rf "$APP"
osacompile -o "$APP" "$SCRIPT_DIR/Transcrire.applescript"
echo "Transcrire est à jour."
