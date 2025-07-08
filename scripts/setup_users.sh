#!/bin/bash

if [[ $EUID -ne 0 ]]
then
	echo "Ar trebui sa rulezi ca root (ex: sudo ./setup_users.sh)"
	exit 1
fi

NUM_LEVELS=5
BASE_HOME="/home"

for i in $(seq -w 1 $NUM_LEVELS)
do
	USER="level_$i"
	PASS="parola$i"
	USER_HOME="$BASE_HOME/$USER"
	CHALLENGE_DIR="challenges/$USER"
	HINT_FILE="hints/$USER.txt"
	FLAG_FILE="flags/$USER.flag"

	#creeaza utilizator cu home propriu
	useradd -m -d "$USER_HOME" -s /bin/bash "$USER"

	#seteaza parola
	echo "$USER:$PASS" | chpasswd

	#restrictioneaza accesul la home-ul altor utilizatori
	chmod 700 "$USER_HOME"

	#copiaza challenge.sh
	if [[ -f "$CHALLENGE_DIR/challenge.sh" ]]
	then
		cp "$CHALLENGE_DIR/challenge.sh" "$USER_HOME/"
		chmod +x "$USER_HOME/challenge.sh"
	fi

	if [[ -f start.sh ]]
	then
		cp start.sh "$USER_HOME/"
		chmod +x "$USER_HOME/start.sh"
		chown "$USER:$USER" "$USER_HOME/start.sh"
	fi

	#copiaza hint-ul
	if [[ -f "$HINT_FILE" ]]
	then
		cp "$HINT_FILE" "$USER_HOME/hint.txt"
	fi

	#copiaza flag-ul
	if [[ "$USER" == "level_01" && -f "$FLAG_FILE" ]] 
	then
		cp "$FLAG_FILE" "$USER_HOME/.hidden_flag"
		chmod 600 "$USER_HOME/.hidden_flag"
		chown root:"$USER" "$USER_HOME/.hidden_flag"
	else
		if [[ -f "$FLAG_FILE" ]] 
		then
			cp "$FLAG_FILE" "$USER_HOME/flag.txt"
			chmod 600 "$USER_HOME/flag.txt"
			chown root:"$USER" "$USER_HOME/flag.txt"
		fi
	fi


	#propietar pe tot home-ul: Level_X
	chown -R "$USER:$USER" "$USER_HOME"

	echo "Utilizator $USER creat cu parola '$PASS' si fisierele aferente."
done



