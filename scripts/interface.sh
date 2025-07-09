#!/bin/bash

source "$(dirname "$0")/utils.sh"

CURRENT_USER=$(whoami)
LEVEL="level_01"  # vom porni automat de la level_01

# introducere nume jucator

if [[ ! -f "$HOME/.ctf_player_name" ]]
then
	read -p "Introdu numele tau de jucator: " PLAYER_NAME
	save_player_name "$PLAYER_NAME"
else
	PLAYER_NAME=$(get_player_name)
fi

USED_HINT=0

while true
do
	clear
	echo "=========================================================="
	echo "                        Linux CTF"
	echo " "
	echo "              Bine ai venit, $CURRENT_USER"
	echo " 	   Jucator: $PLAYER_NAME      User: $CURRENT_USER"
	echo "=========================================================="
	echo " "
	echo "   Nivel curent: $LEVEL"
	echo "    1. Ruleaza provocarea"
	echo "    2. Afiseaza hint"
	echo "    3. Trimite flag"
	echo "    4. Iesi"
	echo " "
	echo "=========================================================="

	read -p "Alege o optiune [1-4]: " opt

	case $opt in
		1) run_challenge "$LEVEL" ;;
		2) USED_HINT=1; show_hint "$LEVEL" ;;
		3) submit_flag "$LEVEL" "$PLAYER_NAME" "$USED_HINT" ;;
		4) echo "La revedere!" ; exit 0 ;;
		*) echo "Optiune invalida!"; sleep 1 ;;
	esac
	read -p "Apasa Enter pentru a continua..."
done


