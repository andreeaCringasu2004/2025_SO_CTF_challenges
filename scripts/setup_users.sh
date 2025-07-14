#!/bin/bash

set -e

LEVEL_COUNT=5
USERS_FILE="scripts/users/users.txt"

mkdir -p scripts/users
> "$USERS_FILE"
chmod 600 "$USERS_FILE"

for i in $(seq -w 1 $LEVEL_COUNT)
do
	USER=$(printf "level_%02d" "$i")
	HOME_DIR="/home/$USER"
	NUM_I=$((10#$i))  # transforma in numar

	# setez parola pt primul nivel separat ca fiind 1234
	# setez parola user-ului ca fiind continutul fara acolade din fiserele de flags
	if [[ "$NUM_I" -eq 1 ]]
	then
		PASSWORD="1234"
	else
		PREV_NUM=$(printf "%02d" $((NUM_I - 1)))
		PREV_FLAG_FILE="flags/level_${PREV_NUM}.flag"

		if [[ -f "$PREV_FLAG_FILE" ]]
		then
			PASSWORD=$(cat "$PREV_FLAG_FILE" | tr -d '{}')
		else
			echo "❌ Lipseste flagul pentru level_$PREV_NUM"
            		exit 1
		fi
	fi


	echo "$USER:$PASSWORD" >> "$USERS_FILE"

	if ! id "$USER" &>/dev/null
	then
		#creeaza utilizator cu home propriu
		useradd -m -d "$HOME_DIR" -s /bin/bash "$USER"
	fi

	#seteaza parola
        echo "$USER:$PASSWORD" | chpasswd

	#restrictioneaza accesul la home-ul altor utilizatori
	chmod 700 "$HOME_DIR" # sau e posibil sa fie nevoie si de sudo


	#copiaza challenge.sh
	CHALLENGE_FILE="challenges/$USER/challenge.sh"
	if [[ -f "$CHALLENGE_FILE" ]]
	then	
		cp "$CHALLENGE_FILE" "$HOME_DIR/challenge.sh"
		chmod 700 "$HOME_DIR/challenge.sh"
		chown "$USER:$USER" "$HOME_DIR/challenge.sh"
	fi

	
	#copiaza hint-ul
	HINT_FILE="hints/${USER}.txt"
	if [[ -f "$HINT_FILE" ]]
	then	
		cp "$HINT_FILE" "$HOME_DIR/hint.txt"
		chmod 644 "$HOME_DIR/hint.txt"
		chown "$USER:$USER" "$HOME_DIR/hint.txt"
	fi

	
	#adaug si fisiere derutante sau inutile

	echo "Continut irelevant, acest fisier nu contine nici-un flag." > "$HOME_DIR/note.txt"
	echo "DEBUG=false" > "$HOME_DIR/debug.sh"
	echo "temporary log" > "$HOME_DIR/tmp.log"

  	chmod 644 "$HOME_DIR/note.txt" "$HOME_DIR/debug.sh" "$HOME_DIR/tmp.log"
  	chown root:"$USER" "$HOME_DIR/note.txt" "$HOME_DIR/debug.sh" "$HOME_DIR/tmp.log"


	# welcome meniu per level
	cat > "$HOME_DIR/welcome.sh" <<EOF
#!/bin/bash
echo " Bine ai venit la nivelul \$USER!"

PS3="Alege o optiune: "
options=("Hint" "Challenge" "Submit Flag" "Iesi")
select opt in "\${options[@]}"
do
	case \$opt in
		"Hint") cat ~/hint.txt ;;
		"Challenge") bash ~/challenge.sh ;;
		"Submit Flag")
			read -p "Introdu flag-ul: " user_flag
			bash /home/andreeagabriela/so-ctf-challenges/scripts/validate_flag.sh \"\$USER\" \"\$User_flag\" \"\$PLAYER\"
			;;
		"Iesi") exit ;;
		*) echo "Optiune invalida" ;;
	esac
done
EOF


	chmod +x "$HOME_DIR/welcome.sh"
	chown $USER:$USER "$HOME_DIR/welcome.sh"
done	

	echo "✅ Utilizatorii au fost creați cu parole corecte: 1234 pt level_01, iar restul – flagurile anterioare."

