# transcrire : whisper.cpp en une commande sur Mac

Transcris n'importe quel fichier audio ou vidéo en texte, en local, sur ton Mac.

## Installation (une seule fois)

```bash
git clone -b claude/compassionate-wright-pspsc2 https://github.com/edouardbouchez9-cmyk/test.git ~/transcrire
cd ~/transcrire
./install.sh
```

Le script installe tout ce qu'il faut : outils Xcode, Homebrew, cmake, ffmpeg,
whisper.cpp (compilé avec Metal) et le modèle `large-v3-turbo`, puis ajoute la
commande `transcrire`.

Pour un modèle plus léger et plus rapide : `./install.sh small`.

## Utilisation

```bash
transcrire interview.m4a            # crée interview.txt à côté du fichier
transcrire -f srt video.mp4         # sous-titres video.srt
transcrire -f all reunion.mp3       # .txt + .srt + .vtt
transcrire -l en podcast.mp3        # audio en anglais (ou -l auto)
transcrire -o note.m4a              # ouvre le texte une fois fini
transcrire *.mp3                    # plusieurs fichiers d'un coup
transcrire                          # puis glisse un fichier dans le Terminal
```

Tous les formats lisibles par ffmpeg sont acceptés : mp3, m4a, wav, mp4, mov, etc.
`transcrire -h` affiche l'aide.

## Réglages

Le fichier `~/.transcrire` enregistre l'emplacement de whisper.cpp et le modèle
utilisé par défaut. Tu peux le modifier, ou passer `-m medium` ponctuellement.
Un modèle absent est téléchargé automatiquement.
