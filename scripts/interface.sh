#!/bin/bash

source "$(dirname "$0")/utils.sh"

mkdir -p history

CURRENT_USER=$(whoami)

# Citesc lista jucatorilor din fisierele din history/
PLAYERS=()
if compgen -G "history/*.log" > /dev/null
then
    for file in history/*.log; do
        # extrag numele jucatorului din numele fisierului (fara .log)
        playername=$(basename "$file" .log)
        PLAYERS+=("$playername")
    done
fi

if [[ ${#PLAYERS[@]} -gt 0 ]]
then
    echo "Jucatori salvati gasiti:"
    
    for i in "${!PLAYERS[@]}"
    do
        echo "  $((i+1)). ${PLAYERS[$i]}"
    done

    echo "  0. Introdu un nume nou"

    read -p "Alege un numar pentru a continua cu jucatorul respectiv sau 0 pentru nume nou: " choice

    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 0 && choice <= ${#PLAYERS[@]} ))
    then
        if (( choice == 0 ))
	then
            read -p "Introdu un nume nou de jucator: " PLAYER_NAME
            save_player_name "$PLAYER_NAME"
        else
            PLAYER_NAME="${PLAYERS[$((choice-1))]}"
            save_player_name "$PLAYER_NAME"
            echo "Ai ales jucatorul: $PLAYER_NAME"
        fi
    else
        echo "Optiune invalida. Iesire."
        exit 1
    fi
else
    # Nu exista niciun jucator salvat, creez nume nou
    read -p "Nu exista niciun jucator salvat. Introdu un nume nou de jucator: " PLAYER_NAME
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

# Functie -  verific toate flagurile salvate pana la nivelulu curent

verify_saved_flags() {
	
	echo "🔎 Verificare flaguri salvate pentru jucator $PLAYER_NAME..."

	LAST_GOOD_LEVEL=""
	STOP_AT_LEVEL=0

	for i in $(seq -w 1 15)
	do
		USER="level_$i"
		USER_HOME="/home/$USER"
		FLAG_FILE="flags/$USER.flag"
		SAVED_FLAGS="$USER_HOME/.found_flags"

		if [[ ! -f "$FLAG_FILE" ]]
		then
			echo "⚠️  Flag oficial lipsa pentru $USER"
			continue
		fi

		REAL_FLAG=$(cat "$FLAG_FILE")

		if [[ -f "$SAVED_FLAGS" ]]
		then
			if grep -q "$REAL_FLAG" "$SAVED_FLAGS"
			then
				echo "✅ $USER: flag corect"
				LAST_GOOD_LEVEL="$USER"
			else
				echo "❌ $USER: flag incorect - eliminam flegurile de la acest nivel in sus"
				STOP_AT_LEVEL=$i
				break;
			fi
		else
			echo "❌ $USER: niciun flag salvat"
            		STOP_AT_LEVEL=$i
            		break
		fi
	done

	if [[ "$STOP_AT_LEVEL" -ne 0 ]]
	then
        	for j in $(seq -w $STOP_AT_LEVEL 15)
		do
            		sudo rm -f "/home/level_$j/.found_flags"
        	done
    	fi

    	if [[ -n "$LAST_GOOD_LEVEL" ]]
	then
        	echo "📌 Ultimul nivel valid: $LAST_GOOD_LEVEL"
        	LEVEL="$LAST_GOOD_LEVEL"
    	else
        	echo "ℹ️ Nu există flaguri valide — se revine la level_01"
        	LEVEL="level_01"
    	fi
}



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
	echo "    4. Verifica flagurile salvate"
	echo "    5. Joaca un nivel anterior (max $LEVEL)"
	echo "    6. Iesi"
	echo " "
	echo "=========================================================="

	read -p "Alege o optiune [1-6]: " opt

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
			verify_saved_flags
			echo -e "Nivelul curent actualizat: $LEVEL"
			;;
		5)
			read -p "Introdu nivelul dorit (ex: level_02): " chosen
		        if [[ "$chosen" =~ ^level_[0-9]{2}$ ]]
			then
				CHOSEN_NUM=$((10#${chosen:6}))
				CURRENT_NUM=$((10#${LEVEL:6}))
				
				if (( CHOSEN_NUM <= CURRENT_NUM ))
				then
                    			su - "$chosen" -c "./welcome.sh"
                		else
                    			echo "❌ Nu ai ajuns încă la $chosen."
                		fi
			else
				echo "⚠️ Format invalid. Scrie ex: level_03"
			fi	
			;;
		6)
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


