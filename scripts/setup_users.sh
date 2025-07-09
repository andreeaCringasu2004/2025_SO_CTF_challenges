#!/bin/bash

set -e

LEVEL_COUNT=5
USERS_FILE="users/users.txt"

mkdir -p users
> "$USERS_FILE"

chmod 600 "$USERS_FILE"
chown root:root "$USERS_FILE"

generate_password() {
	echo "soCTF$(openssl rand -hex 4)"
}

for i in $(seq -w 1 $LEVEL_COUNT)
do
	USER=$(printf "level_%02d" "$i")
	PASSWORD=$(generate_password)
	HOME_DIR="/home/$USER"

	echo "$USER:$PASSWORD" >> "$USERS_FILE"

	if ! id "$USER" &>/dev/null
	then
		#creeaza utilizator cu home propriu
		useradd -m -d "$HOME_DIR" -s /bin/bash "$USER"

		#seteaza parola
		echo "$USER:$PASSWORD" | sudo chpasswd
	fi

	#restrictioneaza accesul la home-ul altor utilizatori
	sudo chmod 700 "$HOME_DIR"

	#copiaza challenge.sh
	CHALLENGE_FILE="challenge/$USER/challenge.sh"
	[[ -f "$CHALLENGE_FILE" ]] && 
		sudo cp "$CHALLENGE_FILE" "$HOME_DIR/challenge.sh" && 
		sudo chmod +x "$HOME_DIR/challenge.sh"

	
	#copiaza hint-ul
	HINT_FILE="hints/$USER.txt"
	[[ -f "$HINT_FILE" ]] && 
		sudo cp "$HINT_FILE" "$HOME_DIR/hint.txt"

	#copiaza flag-ul
	FLAG_FILE="flags/$USER.flag"
	if [[ "$USER" == "level_01" && -f "$FLAG_FILE" ]] 
	then
		sudo cp "$FLAG_FILE" "$HOME_DIR/.hidden_flag"
		echo "FLAG{SO2025CTF_5a0165fd}" > "$HOME_DIR/.hidden_flag"    # adaug flag-ul in in fisierul corespunzator pt level_01
		chmod 640 "$HOME_DIR/.hidden_flag"
		chown root:"$USER" "$HOME_DIR/.hidden_flag"
	else
		if [[ -f "$FLAG_FILE" ]] 
		then
			cp "$FLAG_FILE" "$HOME_DIR/flag.txt"
			chmod 600 "$HOME_DIR/flag.txt"
			chown root:"$USER" "$HOME_DIR/flag.txt"
		fi
	fi
	
	#adaug si fisiere derutante sau inutile

	echo "Continut irelevant, acest fisier nu contine nici-un flag." > "$HOME_DIR/note.txt"
	echo "DEBUG=false" > "$HOME_DIR/debug.sh"
	echo "temporary log" > "$HOME_DIR/tmp.log"

  	chmod 644 "$HOME_DIR/note.txt" "$HOME_DIR/debug.sh" "$HOME_DIR/tmp.log"
  	chown root:"$USER" "$HOME_DIR/note.txt" "$HOME_DIR/debug.sh" "$HOME_DIR/tmp.log"


	#adaug meniul de inceput
	sudo bash -c "cat > '$HOME_DIR/welcome.sh' << 'EOF'
#!/bin/bash
echo \" Bine ai venit la nivelul $USER!\"

PS3=\"Alege o optiune: \"
options=(\"Hint\" \"Challenge\" \"Submit Flag\" \"Iesi\")
select opt in \"\${options[@]}\"
do
	case \$opt in
		\"Hint\") cat ~/hint.txt ;;
		\"Challenge\") bash ~/challenge.sh ;;
		\"Submit FLag\")
			read -p \"Introdu flag-ul: \" user_flag
			bash ~/../scripts/validate_flag.sh \"$USER\" \"\$user_flag\"
			;;
		\"Iesi\") exit ;;
		*) echo \"Optiune invalida\" ;;
	esac
done
EOF"

	sudo chmod +x "$HOME_DIR/welcome.sh"
	sudo chown $USER:$USER "$HOME_DIR/welcome.sh"
done	

	echo "Userii au fost creeati. Verefifica parolele in $USERS_FILE."

