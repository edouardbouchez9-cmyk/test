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
	set progress total steps to total
	set progress completed steps to 0
	set progress description to "Transcription en cours…"

	set reussis to {}
	set erreurs to {}
	repeat with i from 1 to total
		set chemin to POSIX path of (item i of fichiers)
		set progress additional description to "Fichier " & i & " sur " & total & " : " & nomDe(chemin)
		try
			do shell script "export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH; transcrire -l " & langue & " -f " & fmt & " " & quoted form of chemin
			set end of reussis to chemin
		on error msg
			set end of erreurs to nomDe(chemin) & " : " & msg
		end try
		set progress completed steps to i
	end repeat

	if (count of erreurs) > 0 then
		set AppleScript's text item delimiters to return & return
		set texteErreurs to erreurs as text
		set AppleScript's text item delimiters to ""
		if texteErreurs contains "transcrire: command not found" or texteErreurs contains "whisper-cli introuvable" then
			set texteErreurs to "whisper.cpp n'est pas installé. Ouvre le Terminal dans le dossier du projet et lance ./install.sh"
		end if
		display dialog "Certains fichiers n'ont pas pu être transcrits :" & return & return & texteErreurs buttons {"OK"} default button 1 with icon caution with title "Transcrire"
	end if

	if (count of reussis) > 0 then
		if fmt is "srt" then
			set ext to "srt"
		else
			set ext to "txt"
		end if
		set reponse to display dialog "Terminé ! " & (count of reussis) & " fichier(s) transcrit(s)." & return & "Le résultat est enregistré à côté de chaque fichier d'origine." buttons {"OK", "Afficher dans le Finder", "Ouvrir"} default button "Ouvrir" with title "Transcrire"
		set bouton to button returned of reponse
		repeat with chemin in reussis
			set resultat to "f=" & quoted form of (chemin as text) & "; open "
			if bouton is "Afficher dans le Finder" then set resultat to resultat & "-R "
			if bouton is not "OK" then do shell script resultat & "\"${f%.*}." & ext & "\""
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
