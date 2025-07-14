#!/bin/bash

echo "🔁 Resetare utilizatori Linux SO CTF..."

NUM_LEVELS=5
for i in $(seq -w 1 $NUM_LEVELS); do
    USER="level_$i"
    echo "Sterg utilizatorul $USER..."

    # Sterge utilizatorul si home-ul lui
    userdel -r "$USER" 2>/dev/null

    HOME_DIR="/home/$USER"
    if [[ -d "$HOME_DIR" ]]; then
        rm -rf "$HOME_DIR"
    fi
done

# Stergem fișierul cu parole
if [[ -f scripts/users/users.txt ]]; then
    echo "Sterg scripts/users/users.txt..."
    rm scripts/users/users.txt
fi

# Ștergem fișierele de istoric
if [[ -d history ]]; then
    echo "Sterg istoric..."
    rm -f history/*.log
fi

# Ștergem fișierul cu jucătorul curent
if [[ -f "$HOME/.ctf_player_name" ]]; then
    echo "Sterg jucatorul curent salvat..."
    rm "$HOME/.ctf_player_name"
fi

echo "✅ Resetare completă."

