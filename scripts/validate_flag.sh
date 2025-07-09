#!/bin/bash

LEVEL=$1
USER_INPUT_FLAG="$2"
PLAYER="$3"
USED_HINT="$4"
FLAG_FILE="flags/$LEVEL.flag"
USERS_FILE="users/users.txt"

if [[ ! -f "$FLAG_FILE" ]]
then
	echo "Flag-ul pentru acest nivel(nivelul $LEVEL) nu exista!"
	exit 1
fi

REAL_FLAG=$(cat "$FLAG_FILE")

if [[ "$USER_INPUT_FLAG" == "$REAL_FLAG" ]]
then
	echo " Flag corect! Felicitari, ai trecut nivelul $LEVEL!"
	
	#	PLAYER_NAME=$(get_player_name)
	update_score "$PLAYER_NAME" "$LEVEL" "$USED_HINT"

	# pt incrementarea scorului

	CURR_NUM=${LEVEL:6}
	NEXT_NUM=$(printf "%02d" $((10#$CURR_NUM + 1)))
	NEXT_USER="level_$NEXT_NUM"

	if grep -q "^$NEXT_USER:" "$USERS_FILE"
	then
		NEXT_CRED=$(grep "^$NEXT_USER:" "$USERS_FILE")
		echo "Urmatorul nivel: $NEXT_CRED"
	else
		echo "🎉 Ai terminat ultimul nivel!"
	fi
else
    echo " Flagul gasit este incorect. Incearca din nou!"
fi
