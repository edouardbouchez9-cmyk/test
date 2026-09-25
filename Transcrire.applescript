-- Transcrire.app : glisse des fichiers audio ou vidéo sur l'icône,
-- ou double-clique pour les choisir. Utilise la commande « transcrire ».

property nomsFormats : {"Texte (.txt)", "Sous-titres (.srt)", "Texte + sous-titres"}
property codesFormats : {"txt", "srt", "all"}
property nomsLangues : {"Français", "Anglais", "Espagnol", "Allemand", "Italien", "Détection automatique"}
property codesLangues : {"fr", "en", "es", "de", "it", "auto"}

on run
	set fichiers to choose file with prompt "Choisis les fichiers audio ou vidéo à transcrire :" with multiple selections allowed
	transcrireFichiers(fichiers)
end run

on open fichiers
	transcrireFichiers(fichiers)
end open

on transcrireFichiers(fichiers)
	set fmt to choisir(nomsFormats, codesFormats, "Que veux-tu obtenir ?")
	if fmt is missing value then return
	set langue to choisir(nomsLangues, codesLangues, "Langue parlée dans l'audio :")
	if langue is missing value then return

	set total to count of fichiers
	set arguments to ""
	repeat with f in fichiers
		set arguments to arguments & " " & quoted form of (POSIX path of f)
	end repeat
	set progress total steps to total * 100
	set progress completed steps to 0
	set progress description to "Transcription en cours…"
	set progress additional description to "Préparation…"

	set dossierTemp to do shell script "mktemp -d"
	set journal to quoted form of (dossierTemp & "/journal.txt")
	set statut to quoted form of (dossierTemp & "/statut.txt")

	-- Lance la transcription en arrière-plan pour pouvoir suivre sa progression.
	-- -u : plusieurs fichiers sont regroupés dans un seul texte, classés par nom.
	set pid to do shell script "(export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH; transcrire -u -l " & langue & " -f " & fmt & arguments & " > " & journal & " 2>&1; echo $? > " & statut & ") > /dev/null 2>&1 & echo $!"
	try
		repeat
			delay 1
			if (do shell script "test -f " & statut & " && echo fini || echo encours") is "fini" then exit repeat
			-- « numéro pourcentage nom » du fichier en cours
			set etat to do shell script "awk '/^==> /{n++; p=0; nom=substr($0,5)} /progress = /{p=$NF+0} END{print n+0, p+0, nom}' " & journal
			set AppleScript's text item delimiters to " "
			set morceaux to text items of etat
			set n to (item 1 of morceaux) as integer
			set pct to (item 2 of morceaux) as integer
			set nom to (items 3 thru -1 of morceaux) as text
			set AppleScript's text item delimiters to ""
			if n > 0 then
				set progress completed steps to (n - 1) * 100 + pct
				set progress additional description to "Fichier " & n & " sur " & total & " : " & nom & " — " & pct & " %"
			end if
		end repeat
	on error number -128
		-- Bouton « Arrêter » : on stoppe la transcription et ses sous-processus
		do shell script "for p in $(pgrep -P " & pid & "); do pkill -P $p; kill $p; done; kill " & pid & "; rm -rf " & quoted form of dossierTemp & "; true"
		return
	end try
	set progress completed steps to total * 100

	set code to do shell script "cat " & statut
	set texteErreurs to do shell script "grep 'Erreur :' " & journal & " || true"
	if code is not "0" and texteErreurs is "" then set texteErreurs to do shell script "tail -3 " & journal
	set regroupe to do shell script "sed -n 's/^Regroupé : //p' " & journal
	if fmt is "srt" then
		set ext to "srt"
	else
		set ext to "txt"
	end if
	if regroupe is not "" then
		set resultats to {regroupe}
	else
		set resultats to paragraphs of (do shell script "sed -n 's/^Enregistré : //p' " & journal & " | grep '\\." & ext & "$' || true")
	end if
	do shell script "rm -rf " & quoted form of dossierTemp

	if texteErreurs is not "" then
		if texteErreurs contains "command not found" or texteErreurs contains "whisper-cli introuvable" then
			set texteErreurs to "whisper.cpp n'est pas installé. Ouvre le Terminal dans le dossier du projet et lance ./install.sh"
		end if
		display dialog "Certains fichiers n'ont pas pu être transcrits :" & return & return & texteErreurs buttons {"OK"} default button 1 with icon caution with title "Transcrire"
	end if

	if (count of resultats) > 0 and item 1 of resultats is not "" then
		if regroupe is not "" then
			set message to "Terminé ! Tout est regroupé dans :" & return & nomDe(regroupe)
		else
			set message to "Terminé ! " & (count of resultats) & " fichier(s) transcrit(s)." & return & "Le résultat est enregistré à côté de chaque fichier d'origine."
		end if
		set bouton to button returned of (display dialog message buttons {"OK", "Afficher dans le Finder", "Ouvrir"} default button "Ouvrir" with title "Transcrire")
		repeat with resultat in resultats
			if bouton is "Ouvrir" then
				do shell script "open " & quoted form of (resultat as text)
			else if bouton is "Afficher dans le Finder" then
				do shell script "open -R " & quoted form of (resultat as text)
			end if
		end repeat
	end if
end transcrireFichiers

-- Affiche une liste et renvoie le code correspondant au choix (missing value si annulé)
on choisir(noms, codes, question)
	set choix to choose from list noms with title "Transcrire" with prompt question default items {item 1 of noms}
	if choix is false then return missing value
	repeat with i from 1 to count of noms
		if item i of noms is (item 1 of choix) then return item i of codes
	end repeat
end choisir

on nomDe(chemin)
	return do shell script "basename " & quoted form of chemin
end nomDe
