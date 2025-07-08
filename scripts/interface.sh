#!/bin/bash

source "$(dirname "$0")/utils.sh"

CURRENT_USER=$(whoami)
LEVEL="level_01"  # vom porni automat de la level_01

while true
do
	clear
	echo "============================================="
	echo "                  Linux CTF"
	echo ""
	echo "        Bine ai venit, $CURRENT_USER"
	echo "============================================="
	echo ""
	echo " Nivel curent: $LEVEL"
	echo " 1. Ruleaza provocarea"
	echo " 2. Afiseaza hint"
	echo " 3. Trimite flag"
	echo " 4. Iesi"
	echo ""
	echo "============================================="

	read -p "Alege o optiune [1-4]: " opt

	case $opt in
		1) run_challenge "$LEVEL" ;;
		2) show_hint "$LEVEL" ;;
		3) submit_flag "$LEVEL" ;;
		4) echo "La revedere!" ; exit 0 ;;
		*) echo "Optiune invalida!"; sleep 1 ;;
	esac
	echo ""
	read -p "Apasa Enter pentru a continua..."
done


