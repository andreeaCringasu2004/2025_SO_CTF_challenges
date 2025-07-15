#!/bin/bash

set -e

LEVEL_COUNT=15
USERS_FILE="scripts/users/users.txt"

mkdir -p scripts/users
> "$USERS_FILE"
chmod 600 "$USERS_FILE"

for i in $(seq -w 1 $LEVEL_COUNT)
do
	NUMERIC_I=$((10#$i))
	USER=$(printf "level_%02d" "$NUMERIC_I")
	HOME_DIR="/home/$USER"

	# setez parola pt primul nivel separat ca fiind 1234
	# setez parola user-ului ca fiind continutul fara acolade din fiserele de flags
	if [[ "$NUMERIC_I" -eq 1 ]]
	then
		PASSWORD="1234"
	else
		#Elimina zero-urile din fata pt a obt val numerica singura
		# VALOARE_NUMERICA=$(echo "$NUM_I" | sed 's/^0*//')
		PREV_NUM=$(printf "%02d" $((NUMERIC_I - 1)))
		PREV_FLAG_FILE="flags/level_${PREV_NUM}.flag"

		if [[ -f "$PREV_FLAG_FILE" ]]
		then
			PASSWORD=$(grep -oP '(?<=FLAG\{)soCTF_[^}]+(?=\})' "$PREV_FLAG_FILE")
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

	# Setup specific pentru fiecare nivel
	if [[ "$USER" == "level_01" ]]; then
		echo "FLAG{soCTF_42dc5c40}" > "$HOME_DIR/.hidden_flag"
		chmod 644 "$HOME_DIR/.hidden_flag"
		chown "$USER:$USER" "$HOME_DIR/.hidden_flag"
	fi

	if [[ "$USER" == "level_02" ]]; then
		mkdir -p "$HOME_DIR/logs"
		for i in {1..200}; do echo "Linie zgomot $i" >> "$HOME_DIR/logs/sys.log"; done
		echo "FLAG{soCTF_74593aaf}" >> "$HOME_DIR/logs/sys.log"
		echo "ALTceva" > "$HOME_DIR/logs/debug.tmp"
		echo "FLAG_fake{not_the_real_one}" >> "$HOME_DIR/logs/debug.tmp"
		chown -R "$USER:$USER" "$HOME_DIR/logs"
	fi

	if [[ "$USER" == "level_03" ]]; then
		echo "FLAG{soCTF_d6b126fa}" > "$HOME_DIR/flag_secret"
		chmod 000 "$HOME_DIR/flag_secret"
		chown "$USER:$USER" "$HOME_DIR/flag_secret"
		echo "Nu e aici flagul" > "$HOME_DIR/fake.txt"
		chmod 644 "$HOME_DIR/fake.txt"
		chown "$USER:$USER" "$HOME_DIR/fake.txt"
	fi

	if [[ "$USER" == "level_04" ]]; then
		echo -n "FLAG{soCTF_c14b4df9}" | base64 > "$HOME_DIR/encrypted.txt"
		echo -n "Nu este flagul!" | base64 > "$HOME_DIR/notes.b64"
		chown "$USER:$USER" "$HOME_DIR/encrypted.txt" "$HOME_DIR/notes.b64"
	fi

	if [[ "$USER" == "level_05" ]]; then
		mkdir -p "$HOME_DIR/old/conf"
		echo "FLAG{soCTF_fbd6e45d}" > "$HOME_DIR/old/conf/flag.bak"
		echo "backup inutil" > "$HOME_DIR/old/conf/config.bak"
		echo "not the flag" > "$HOME_DIR/old/conf/not_the_flag.txt"
		chown -R "$USER:$USER" "$HOME_DIR/old"
	fi

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

