#!/bin/bash

source "$(dirname "$0")/utils.sh"

mkdir -p history

CURRENT_USER=$(whoami)

# introducere nume jucator (inregistrare sau citire jucator)
if [[ -f "$HOME/.ctf_player_name" ]]
then
	OLD_PLAYER=$(cat "$HOME/.ctf_player_name")
	echo "Jucator curent salvat: $OLD_PLAYER"
	read -p "Vrei sa continui cu acest jucator? [Y/N]: " raspuns
	if [[ "$raspuns" =~ ^[Yy]$ ]]
	then
		PLAYER_NAME="$OLD_PLAYER"
	else
		read -p "Introdu un nou nume de jucator: " PLAYER_NAME
		save_player_name "$PLAYER_NAME"
	fi
else	
	read -p "Nu exista niciun ucator salvat. Introdu numele tau de jucator: " PLAYER_NAME
	save_player_name "$PLAYER_NAME"
fi


# fisier istoric specific jucatorului
HISTORY_FILE="history/${PLAYER_NAME}.log"

# determinare nivel curent
if [[ -f "$HISTORY_FILE" ]]
then
	LAST_LEVEL=$(grep "LEVEL=" "$HISTORY_FILE" | tail -n1 | cut -d'=' -f2 | cut -d' ' -f1)
else
	LAST_LEVEL="level_01"
fi

LEVEL="$LAST_LEVEL"
USED_HINT=0


# Meniul principal
while true
do
	clear
	echo "=========================================================="
	echo "                      Linux SO CTF"
	echo " "
	echo "              Bine ai venit, $CURRENT_USER"
	echo "        Jucator: $PLAYER_NAME      User: $CURRENT_USER"
	echo " "
	echo "=========================================================="
	echo "                 Nivel curent: $LEVEL"
	echo "=========================================================="
	echo " "
	echo "    1. Ruleaza provocarea"
	echo "    2. Afiseaza hint"
	echo "    3. Trimite flag"
	echo "    4. Iesi"
	echo " "
	echo "=========================================================="

	read -p "Alege o optiune [1-4]: " opt

	case $opt in
		1) 
			# run_challenge "$LEVEL"
			echo "Intrare in provocare ca user $LEVEL..."
			
			if [[ "$LEVEL" == "level_01" ]]
			then
				#FIRST_PASS=$(grep "^level_01:" scripts/users/users.txt | cut -d':' -f2)  #echo -e "🔑 Parola pentru $LEVEL este: $FIRST_PASS"
				echo -e "🔑 Parola pentru level_01 este: 1234"
			fi

			su - "$LEVEL" -c "./welcome.sh"

			run_challenge "$LEVEL"

			# su - "$LEVEL" -c "./welcome.sh"
			;;
		2) 
			USED_HINT=1; 
			show_hint "$LEVEL" 
			;;
		3) 
			submit_flag "$LEVEL" "$PLAYER_NAME" "$USED_HINT" 
			
			#actualizam nivelul curent doar daca a fost rezolvat corect
			if [[ $? -eq 0 ]]
			then
				LEVEL=$(next_level "$LEVEL")
				echo -e "\n Treci la nivelul urmator doar dupa validarea flagului!"
				USED_HINT=0
			fi
			;;
		4)
			echo "La revedere!" ; 
			exit 0 
			;;
		*) 
			echo "❌ Optiune invalida!"; 
			sleep 1 
			;;
	esac

	read -p "Apasa Enter pentru a continua..."
done


