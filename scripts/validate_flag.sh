#!/bin/bash

LEVEL=$1
USER_INPUT_FLAG="$2"
PLAYER="$3"
USED_HINT="$4"

FLAG_FILE="flags/$LEVEL.flag"
USERS_FILE="scripts/users/users.txt"
HISTORY_FILE="history/${PLAYER}.log"

# verific existenta fisierului flag
if [[ ! -f "$FLAG_FILE" ]]
then
	echo "Flag-ul pentru nivelul $LEVEL nu exista!"
	exit 1
fi

# citesc flagul corect
REAL_FLAG=$(cat "$FLAG_FILE")

if [[ "$USER_INPUT_FLAG" == "$REAL_FLAG" ]]
then
	echo " Flag corect! Felicitari, ai trecut nivelul $LEVEL!"
	
	# determin scorul
	SCORE=$(( USED_HINT == 1 ? 10 : 30 ))

	# salvez scorul si progresul
	source "$(dirname "$0")/utils.sh"
	update_score "$PLAYER" "$LEVEL" "$USED_HINT" "$SCORE"

	# calculez urmatorul nivel
	CURR_NUM=${LEVEL:6}
	NEXT_NUM=$(printf "%02d" $((10#$CURR_NUM + 1)))
	NEXT_USER="level_$NEXT_NUM"

	if id "$NEXT_USER" &>/dev/null
	then
		# extrag parola pt urmatorul user ca fiind flagul gasit, doar partea dintre acolade
		PASSWORD=$(grep -oP '(?<=FLAG\{).*(?=\})' "$FLAG_FILE")

		# setez parola
		echo "$NEXT_USER:$PASSWORD" | chpasswd

		CREDS="User: $NEXT_USER | Parola: $PASSWORD"
        	echo -e "\n🔐 $CREDS"
        	echo -e "\n🔓 Parola setata pentru $NEXT_USER"

		record_level "$PLAYER" "$LEVEL" "$USED_HINT" "$SCORE" "$CREDS"
	else
		echo -e "\n🎉 Ai terminat ultimul nivel!"
        	record_level "$PLAYER" "$LEVEL" "$USED_HINT" "$SCORE" "Ultimul nivel"
    	fi

	exit 0
else
    echo "❌ Flag-ul este incorect. Incearcă din nou."
    exit 1
fi
