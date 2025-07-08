#!/bin/bash

function run_challenge() {
	LEVEL="$1"
	CHALLENGE_FILE="challenges/${LEVEL}/challenge.sh"

	if [[ -x "$CHALLENGE_FILE" ]]
	then
		echo "Provocarea:"
		bash "$CHALLENGE_FILE"
	else
		echo "Fisierul pt provocare nu exista sau nu este executabil."
	fi
}

function show_hint() {
	LEVEL="$1"
	HINT_FILE="hints/${LEVEL}.txt"

	if [[ -f "$HINT_FILE" ]]; then
		echo " Hint pentru $LEVEL:"
		cat "$HINT_FILE"
	else
		echo "Nu exista hint pentru $LEVEL"
	fi
}

function submit_flag()
{
	LEVEL="$1"
	read -p "Introdu flag-ul pentru "$LEVEL: " user_flag
	bash scripts/validate_flag.sh "$LEVEL" "$user_flag"
}

