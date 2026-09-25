#!/bin/bash
# Installe whisper.cpp sur macOS et ajoute la commande « transcrire ».
#
# Usage : ./install.sh [modele]
#   modele : large-v3-turbo (par défaut), small, base, medium, large-v3...

set -euo pipefail

WHISPER_DIR="${WHISPER_DIR:-$HOME/whisper.cpp}"
MODEL="${1:-large-v3-turbo}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
erreur() { printf '\033[1;31mErreur :\033[0m %s\n' "$*" >&2; exit 1; }

[ "$(uname)" = "Darwin" ] || erreur "ce script est prévu pour macOS."

# 1. Outils de compilation Apple
if ! xcode-select -p >/dev/null 2>&1; then
  info "Installation des outils de ligne de commande Xcode..."
  xcode-select --install || true
  erreur "termine l'installation dans la fenêtre qui s'est ouverte, puis relance ./install.sh"
fi

# 2. Homebrew
if ! command -v brew >/dev/null 2>&1; then
  info "Installation de Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# 3. cmake et ffmpeg
info "Installation de cmake et ffmpeg..."
brew install cmake ffmpeg

# 4. Récupération de whisper.cpp
if [ -d "$WHISPER_DIR/.git" ]; then
  info "Mise à jour de whisper.cpp dans $WHISPER_DIR..."
  git -C "$WHISPER_DIR" pull --ff-only
else
  info "Téléchargement de whisper.cpp dans $WHISPER_DIR..."
  git clone https://github.com/ggml-org/whisper.cpp.git "$WHISPER_DIR"
fi

# 5. Compilation (Metal activé par défaut sur Apple Silicon)
info "Compilation (quelques minutes)..."
cmake -S "$WHISPER_DIR" -B "$WHISPER_DIR/build" -DCMAKE_BUILD_TYPE=Release
cmake --build "$WHISPER_DIR/build" -j --config Release

# 6. Modèle
if [ -f "$WHISPER_DIR/models/ggml-$MODEL.bin" ]; then
  info "Modèle $MODEL déjà présent."
else
  info "Téléchargement du modèle $MODEL..."
  sh "$WHISPER_DIR/models/download-ggml-model.sh" "$MODEL"
fi

# 7. Commande « transcrire »
BIN_DIR="$(brew --prefix)/bin"
info "Installation de la commande transcrire dans $BIN_DIR..."
install -m 755 "$SCRIPT_DIR/transcrire" "$BIN_DIR/transcrire"

# Mémorise l'emplacement et le modèle choisis
printf 'WHISPER_DIR="%s"\nWHISPER_MODEL="%s"\n' "$WHISPER_DIR" "$MODEL" > "$HOME/.transcrire"

# 8. Application « Transcrire » (fabriquée ici, donc pas bloquée par Gatekeeper)
APP_DIR="/Applications"
[ -w "$APP_DIR" ] || { APP_DIR="$HOME/Applications"; mkdir -p "$APP_DIR"; }
info "Création de l'application Transcrire dans $APP_DIR..."
rm -rf "$APP_DIR/Transcrire.app"
osacompile -o "$APP_DIR/Transcrire.app" "$SCRIPT_DIR/Transcrire.applescript"

echo
info "Terminé !"
echo "  • Ouvre « Transcrire » depuis le Launchpad ou le dossier $APP_DIR,"
echo "    ou glisse des fichiers audio/vidéo sur son icône (pense à la mettre dans le Dock)."
echo "  • Dans le Terminal : transcrire ~/Desktop/mon_audio.mp3"
open -R "$APP_DIR/Transcrire.app"
