#!/bin/bash
# Met à jour l'app Transcrire et la commande transcrire, sans tout réinstaller.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

git -C "$SCRIPT_DIR" pull --ff-only
install -m 755 "$SCRIPT_DIR/transcrire" "$SCRIPT_DIR/decouper" "$(brew --prefix)/bin/"

if [ -d "$HOME/Applications/Transcrire.app" ] && [ ! -d /Applications/Transcrire.app ]; then
  APP_DIR="$HOME/Applications"
else
  APP_DIR="/Applications"
fi
rm -rf "$APP_DIR/Transcrire.app" "$APP_DIR/Découper.app"
osacompile -o "$APP_DIR/Transcrire.app" "$SCRIPT_DIR/Transcrire.applescript"
osacompile -o "$APP_DIR/Découper.app" "$SCRIPT_DIR/Decouper.applescript"
echo "Transcrire et Découper sont à jour."
open -R "$APP_DIR/Découper.app"
