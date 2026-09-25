# Transcrire : whisper.cpp en une app sur Mac

Transcris n'importe quel fichier audio ou vidéo en texte, en local, sur ton Mac.
Aucune donnée n'est envoyée sur internet.

## Installation (une seule fois)

```bash
git clone -b claude/compassionate-wright-pspsc2 https://github.com/edouardbouchez9-cmyk/test.git ~/transcrire
cd ~/transcrire
./install.sh
```

Le script installe tout ce qu'il faut : outils Xcode, Homebrew, cmake, ffmpeg,
whisper.cpp (compilé avec Metal) et le modèle `large-v3-turbo`, puis crée
l'application **Transcrire** dans `/Applications` et la commande `transcrire`.

Pour un modèle plus léger et plus rapide : `./install.sh small`.

## Utilisation de l'app

- **Glisse** un ou plusieurs fichiers audio/vidéo sur l'icône de Transcrire
  (dans le Dock ou le Finder), ou **double-clique** dessus pour les choisir.
- Choisis le résultat voulu (texte, sous-titres ou les deux) et la langue.
- **Plusieurs fichiers d'un coup** : tout est regroupé dans un seul texte
  `<premier fichier> - transcription complète.txt`, classé par nom (Cours 2 avant
  Cours 10), avec la ligne « transcription 10 min finit » entre chaque fichier.
- Une fenêtre affiche le pourcentage d'avancement (bouton **Arrêter** pour annuler).
  Au tout début, la préparation et le chargement du modèle peuvent prendre un moment. À la fin, clique sur **Ouvrir** pour lire
  le texte, qui est enregistré à côté du fichier d'origine.

## Utilisation dans le Terminal

```bash
transcrire interview.m4a            # crée interview.txt à côté du fichier
transcrire -f srt video.mp4         # sous-titres video.srt
transcrire -f all reunion.mp3       # .txt + .srt + .vtt
transcrire -l en podcast.mp3        # audio en anglais (ou -l auto)
transcrire -o note.m4a              # ouvre le texte une fois fini
transcrire *.mp3                    # plusieurs fichiers d'un coup
transcrire -u cours-*.m4a           # tout regroupé dans un seul texte
transcrire                          # puis glisse un fichier dans le Terminal
```

Tous les formats lisibles par ffmpeg sont acceptés : mp3, m4a, wav, mp4, mov, etc.
`transcrire -h` affiche l'aide.

## Réglages

Le fichier `~/.transcrire` enregistre l'emplacement de whisper.cpp et le modèle
utilisé par défaut. Tu peux le modifier, ou passer `-m medium` ponctuellement.
Un modèle absent est téléchargé automatiquement.

## Mise à jour

```bash
cd ~/transcrire && ./mettre-a-jour.sh
```
