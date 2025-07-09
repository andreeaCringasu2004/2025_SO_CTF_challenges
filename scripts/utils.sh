#!/bin/bash

run_challenge() {
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

show_hint() {
	LEVEL="$1"
	HINT_FILE="hints/${LEVEL}.txt"

	if [[ -f "$HINT_FILE" ]]; then
		echo " Hint pentru $LEVEL:"
		cat "$HINT_FILE"
	else
		echo "Nu exista hint pentru $LEVEL"
	fi
}

submit_flag()
{
	LEVEL="$1"
	read -p "Introdu flag-ul pentru $LEVEL: " user_flag
	bash scripts/validate_flag.sh "$LEVEL" "$user_flag"
}

save_player_name() {
	echo "$1" > "$HOME/.ctf_player_name"
}

get_player_name() {
	cat "$HOME/.ctf_player_name"
}

update_score() {
	local player_name="$1"
	local level="$2"
	local used_hint="$3"
	local score_file="users/scores.txt"
	local points=$(( used_hint == 1 ? 50 : 100 ))
	local total=0

	mkdir -p users
	touch "$score_file"

	# actualizeaza scorul curent
	echo "$player_name $level $used_hint $points" >> "$score_file"

	total=$(awk -v name="$player_name" '$1==name {sum+=$4} END {print sum}' "$score_file")
	echo "Scor total actualizat: $total puncte"
}




