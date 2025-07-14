#!/bin/bash

run_challenge() {
	LEVEL="$1"
	CHALLENGE_FILE="challenges/${LEVEL}/challenge.sh"

	if [[ -x "$CHALLENGE_FILE" ]]
	then
		echo -e "\n=== Provocare pentru nivelul $LEVEL ==="
		cat "$CHALLENGE_FILE" | grep -v '^#' # afișează doar liniile semnificative
	else
		echo "Provocarea pentru $LEVEL nu exista sau nu este executabila."
	fi

	# echo -e "\nIntrare în provocare ca user $LEVEL..."
	# su - "$LEVEL" -c "./welcome.sh"
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
	local level="$1"
	local player="$2"
	local used_hint="$3"
	local history_file="history/${player}.log"

	read -p "Introdu flag-ul pentru $level: " user_flag

	if validate_flag "$level" "$user_flag"; then
		local next_level
		next_level=$(next_level "$level")

		# salvare parola ca parola pentru urmatorul user
		echo "${next_level}:${user_flag}" | sudo chpasswd

		local score=$(( used_hint == 1 ? 50 : 100 ))
		local creds="User: $next_level | Parola: $user_flag"

		update_score "$player" "$level" "$used_hint" "$score"
		record_level "$player" "$level" "$used_hint" "$score" "$creds"

		echo -e "\n✅ Corect! Treci la nivelul $next_level."
		return 0
	else
		echo "❌ Flag incorect!"
		return 1
	fi

	#bash scripts/validate_flag.sh "$LEVEL" "$user_flag"
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
	local score="$4"
	local score_file="users/scores.txt"

	mkdir -p users
	touch "$score_file"

	echo "$player_name $level $used_hint $score" >> "$score_file"

	local total
	total=$(awk -v name="$player_name" '$1==name {sum+=$4} END {print sum}' "$score_file")
	echo "Scor total actualizat pentru $player_name: $total puncte"
}

get_score() {
	local level="$1"
	local used_hint="$2" # 0 sau 1
	local score_file="levels/score_map.txt"

	if [[ ! -f "$score_file" ]]
	then
		echo "0"
		return
	 fi

	if (( used_hint == 1 ))
	then
		awk -v lvl="$level" '$1==lvl {for(i=2;i<=NF;i++) if($i ~ /^hint=/) {split($i,a,"="); print a[2]}}' "$score_file"
	else
		awk -v lvl="$level" '$1==lvl {for(i=2;i<=NF;i++) if($i ~ /^nohint=/) {split($i,a,"="); print a[2]}}' "$score_file"
	fi
}

record_level() {
	local player="$1" level="$2" used_hint="$3" score="$4" creds="$5"
	local hist="history/$player.log"
	mkdir -p history
	echo "LEVEL=$level HINT=$used_hint SCORE=$score CREDS='$creds'" >> "$hist"
}

get_levels() {
	local hist="history/$(get_player_name).log"
	[[ -f "$hist" ]] && awk -F'[ =]' '/LEVEL=/{for(i=1;i<=NF;i++) if($i=="LEVEL") print $(i+1)}' "$hist"
}

validate_flag() {
	local level="$1"
	local input_flag="$2"
	local correct_flag_file="flags/${level}.flag"

	if [[ ! -f "$correct_flag_file" ]]
	then
		echo "Lipseste fisierul flag pentru $level"
		return 1
	fi

	local correct_flag
	correct_flag=$(cat "$correct_flag_file")

	[[ "$input_flag" == "$correct_flag" ]]
}

next_level() {
	local current_level="$1"
	local num=$(echo "$current_level" | grep -o '[0-9]\+')
	local next_num=$(printf "%02d" $((10#$num + 1)))
	echo "level_$next_num"
}
