-- Découper.app : glisse des fichiers audio ou vidéo sur l'icône,
-- ou double-clique pour les choisir. Utilise la commande « decouper ».

property nomsDurees : {"5 minutes", "10 minutes", "15 minutes", "20 minutes", "30 minutes"}
property codesDurees : {"5", "10", "15", "20", "30"}

on run
	set fichiers to choose file with prompt "Choisis les fichiers audio ou vidéo à découper :" with multiple selections allowed
	decouperFichiers(fichiers)
end run

on open fichiers
	decouperFichiers(fichiers)
end open

on decouperFichiers(fichiers)
	set choix to choose from list nomsDurees with title "Découper" with prompt "Durée de chaque tranche :" default items {"10 minutes"}
	if choix is false then return
	repeat with i from 1 to count of nomsDurees
		if item i of nomsDurees is (item 1 of choix) then set duree to item i of codesDurees
	end repeat

	set total to count of fichiers
	set progress total steps to total
	set progress completed steps to 0
	set progress description to "Découpage en cours…"

	set dossiers to {}
	set erreurs to {}
	repeat with i from 1 to total
		set chemin to POSIX path of (item i of fichiers)
		set progress additional description to "Fichier " & i & " sur " & total & " : " & (do shell script "basename " & quoted form of chemin)
		try
			set sortie to do shell script "export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH; decouper -d " & duree & " " & quoted form of chemin
			set end of dossiers to do shell script "printf '%s\\n' " & quoted form of sortie & " | sed -n 's/^Dossier : //p'"
		on error msg
			set end of erreurs to msg
		end try
		set progress completed steps to i
	end repeat

	if (count of erreurs) > 0 then
		set AppleScript's text item delimiters to return & return
		set texteErreurs to erreurs as text
		set AppleScript's text item delimiters to ""
		if texteErreurs contains "command not found" then
			set texteErreurs to "La commande decouper n'est pas installée. Dans le Terminal : cd ~/transcrire && git pull && ./mettre-a-jour.sh"
		end if
		display dialog "Certains fichiers n'ont pas pu être découpés :" & return & return & texteErreurs buttons {"OK"} default button 1 with icon caution with title "Découper"
	end if

	if (count of dossiers) > 0 then
		set bouton to button returned of (display dialog "Terminé ! Les tranches de " & duree & " min sont rangées dans un dossier « … - tranches » à côté de chaque fichier." buttons {"OK", "Ouvrir le dossier"} default button "Ouvrir le dossier" with title "Découper")
		if bouton is "Ouvrir le dossier" then
			repeat with dossier in dossiers
				do shell script "open " & quoted form of (dossier as text)
			end repeat
		end if
	end if
end decouperFichiers
