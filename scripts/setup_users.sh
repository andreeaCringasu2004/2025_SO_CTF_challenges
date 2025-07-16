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
	if [[ "$USER" == "level_01" ]]
	then
		echo "FLAG{soCTF_42dc5c40}" > "$HOME_DIR/.hidden_flag"
		chmod 644 "$HOME_DIR/.hidden_flag"
		chown "$USER:$USER" "$HOME_DIR/.hidden_flag"
	fi

	if [[ "$USER" == "level_02" ]]
	then
		mkdir -p "$HOME_DIR/logs"
		for i in {1..200}; do echo "Linie zgomot $i" >> "$HOME_DIR/logs/sys.log"; done
		echo "FLAG{soCTF_74593aaf}" >> "$HOME_DIR/logs/sys.log"
		
		echo "ALTceva" > "$HOME_DIR/logs/debug.tmp"
		echo "FLAG_fake{not_the_real_one}" >> "$HOME_DIR/logs/debug.tmp"
		chown -R "$USER:$USER" "$HOME_DIR/logs"
	fi

	if [[ "$USER" == "level_03" ]]
	then
		echo "FLAG{soCTF_d6b126fa}" > "$HOME_DIR/flag_secret"
		chmod 000 "$HOME_DIR/flag_secret"
		chown "$USER:$USER" "$HOME_DIR/flag_secret"
		
		echo "Nu e aici flagul" > "$HOME_DIR/fake.txt"
		chmod 644 "$HOME_DIR/fake.txt"
		chown "$USER:$USER" "$HOME_DIR/fake.txt"
	fi

	if [[ "$USER" == "level_04" ]]
	then
		echo -n "FLAG{soCTF_c14b4df9}" | base64 > "$HOME_DIR/encrypted.txt"
		
		echo -n "Nu este flagul!" | base64 > "$HOME_DIR/notes.b64"
		chown "$USER:$USER" "$HOME_DIR/encrypted.txt" "$HOME_DIR/notes.b64"
	fi

	if [[ "$USER" == "level_05" ]]
	then
		mkdir -p "$HOME_DIR/old/conf"
		echo "FLAG{soCTF_fbd6e45d}" > "$HOME_DIR/old/conf/flag.bak"
		
		echo "backup inutil" > "$HOME_DIR/old/conf/config.bak"
		echo "not the flag" > "$HOME_DIR/old/conf/not_the_flag.txt"
		chown -R "$USER:$USER" "$HOME_DIR/old"
	fi

	if [[ "$USER" == "level_06" ]]
	then
		echo "cat \"FLAG{soCTF_e2fa1725}\"" >> "$HOME_DIR/.bash_history"
		echo "echo test" >> "$HOME_DIR/.bash_history"
		echo "cat fake_flag.txt" > "$HOME_DIR/fake_flag.txt"
		chown "$USER:$USER" "$HOME_DIR/.bash_history" "$HOME_DIR/fake_flag.txt"
		chmod 600 "$HOME_DIR/.bash_history"
	fi

	if [[ "$USER" == "level_07" ]]
	then
		mkdir -p "$HOME_DIR/scripts"
		echo "echo 'FLAG{soCTF_8e309d51}' > /home/$USER/cron_flag.txt" > "$HOME_DIR/scripts/gen_flag.sh"
		chmod +x "$HOME_DIR/scripts/gen_flag.sh"
		(crontab -l -u "$USER" 2>/dev/null; echo "*/1 * * * * $HOME_DIR/scripts/gen_flag.sh") | crontab -u "$USER" -
		chown -R "$USER:$USER" "$HOME_DIR/scripts"
	fi

	if [[ "$USER" == "level_08" ]]
	then
		mkdir -p "$HOME_DIR/tmp"
		echo "FLAG{soCTF_26aa579f}" > "$HOME_DIR/tmp/level08_tempflag"
		chown "$USER:$USER" "$HOME_DIR/tmp/level08_tempflag"
	fi

	if [[ "$USER" == "level_09" ]]
	then
		mkdir -p "$HOME_DIR/archive"
		echo "FLAG{soCTF_9625ce01}" > "$HOME_DIR/archive/real_flag.txt"
		echo "Nu e aici" > "$HOME_DIR/archive/fake.txt"
		tar -czf "$HOME_DIR/archive.tar.gz" -C "$HOME_DIR/archive" .
		rm -r "$HOME_DIR/archive"
		chown "$USER:$USER" "$HOME_DIR/archive.tar.gz"
	fi

	if [[ "$USER" == "level_10" ]]
	then
		echo -e "#!/bin/bash\necho \"FLA{broken_script}\"" > "$HOME_DIR/script.sh"
		echo "FLAG{soCTF_561bd3b8}" > "$HOME_DIR/real_flag.txt"
		chmod +x "$HOME_DIR/script.sh"
		chown "$USER:$USER" "$HOME_DIR/script.sh" "$HOME_DIR/real_flag.txt"
	fi

	if [[ "$USER" == "level_11" ]]
	then
		echo "FLAG{soCTF_b72efb34}" > "$HOME_DIR/plain_flag.txt"
		gpg --batch --yes --passphrase "ctfkey" -c "$HOME_DIR/plain_flag.txt"
		rm "$HOME_DIR/plain_flag.txt"
		chown "$USER:$USER" "$HOME_DIR/plain_flag.txt.gpg"
	fi

	if [[ "$USER" == "level_12" ]]
	then
		echo "placeholder" > "$HOME_DIR/secret.txt"
		setfattr -n user.flag -v "FLAG{soCTF_39ce7d65}" "$HOME_DIR/secret.txt"
		chown "$USER:$USER" "$HOME_DIR/secret.txt"
	fi

	if [[ "$USER" == "level_13" ]]
	then
		echo "while true; do echo 'FLAG{soCTF_1c435f8f}' | nc -l -p 4444; done" > "$HOME_DIR/socket_server.sh"
		chmod +x "$HOME_DIR/socket_server.sh"
		chown "$USER:$USER" "$HOME_DIR/socket_server.sh"
	fi

	if [[ "$USER" == "level_14" ]]
	then
		echo -e "#!/bin/bash\nVAR=\"\"\n# aici ar trebui citit flagul\ncat flagfile.txt > \$VAR" > "$HOME_DIR/run.sh"
		echo "FLAG{soCTF_62c77b98}" > "$HOME_DIR/flagfile.txt"
		chmod +x "$HOME_DIR/run.sh"
		chown "$USER:$USER" "$HOME_DIR/run.sh" "$HOME_DIR/flagfile.txt"
	fi

	if [[ "$USER" == "level_15" ]]
	then
		mkdir -p "$HOME_DIR/maze/a/1" "$HOME_DIR/maze/a/2" "$HOME_DIR/maze/a/3" "$HOME_DIR/maze/b/1" "$HOME_DIR/maze/b/2" "$HOME_DIR/maze/b/3" "$HOME_DIR/maze/c/1" "$HOME_DIR/maze/c/2" "$HOME_DIR/maze/c/3" "$HOME_DIR/maze/d/1" "$HOME_DIR/maze/d/2" "$HOME_DIR/maze/d/3" "$HOME_DIR/maze/e/1" "$HOME_DIR/maze/e/2" "$HOME_DIR/maze/e/3"
		touch "$HOME_DIR/maze/a/1/trap.txt"
		touch "$HOME_DIR/maze/e/3/fakefile.b64"
		echo "FLAG{soCTF_02e066d3}" > "$HOME_DIR/maze/d/2/flag.final"
		chmod -R 700 "$HOME_DIR/maze"
		chown -R "$USER:$USER" "$HOME_DIR/maze"
	fi

	# welcome meniu per level
	cat > "$HOME_DIR/welcome.sh" <<EOF
#!/bin/bash

FLAG_STORAGE="\$HOME/.found_flags"
touch "\$FLAG_STORAGE"

echo " Bine ai venit la nivelul \$USER!"

PS3="Alege o optiune: "
options=(
	"Hint" 
	"Afisare Challenge" 
	"Terminal Simulat" 
	"Verifica flag"
	"Salveaza flag"
	"Vezi flagurile salvate"
	"Iesi"
)
select opt in "\${options[@]}"
do
	case \$REPLY in
		1) 
			cat ~/hint.txt 
			;;
		2) 
			if [[ -x ~/challenge.sh ]]
			then
				bash ~/challenge.sh 
			else
				echo "⚠️ Nu exista provocare pentru acest nivel."
			fi
			;;
		3)
			echo "Terminal Simulat activ. Scrie 'exit' sau 'quit' pentru a iesi."
			while true
			do
				read -e -p "\$USER\$ " cmd
				if [[ "\$cmd" == "exit" || "\$cmd" == "quit" ]]
				then
					break
				fi
				eval "\$cmd" 2>&1
			done
			;;
		4)
			read -p "Introdu flag-ul pentru verificare: " user_flag
			
			# SCRIPT_DIR="\$(dirname \"\$BASH_SOURCE\")"
			# FLAG_FILE="\$SCRIPT_DIR/../../flags/\$USER.flag"

			FLAG_FILE="/home/andreeagabriela/so-ctf-challenges/flags/\$USER.flag"
			
			if [[ -f "\$FLAG_FILE" ]]
			then
				expected=\$(cat "\$FLAG_FILE")
				if [[ "\$user_flag" == "\$expected" ]]
				then
					echo "✅ Flag corect!"
				else
					echo "❌ Flag incorect."
				fi
			else
				echo "⚠️ Flag-ul oficial pentru acest nivel nu exista."
			fi
			;;
		5)
			read -p "Introdu flag-ul gasit: " f
      			echo "\$f" >> "\$FLAG_STORAGE"
      			echo "💾 Flag-ul a fost salvat temporar in \$FLAG_STORAGE."
      			;;
		6)
			echo "📜 Flaguri salvate temporar:"
      			cat "\$FLAG_STORAGE"
      			;;
		7) 
			echo "La revedere!"
			exit 
			;;
		*) 
			echo "❌ Optiune invalida" 
			;;
	esac
done
EOF


	chmod +x "$HOME_DIR/welcome.sh"
	chown $USER:$USER "$HOME_DIR/welcome.sh"
done	

	echo "✅ Utilizatorii au fost creați cu parole corecte: 1234 pt level_01, iar restul – flagurile anterioare."

