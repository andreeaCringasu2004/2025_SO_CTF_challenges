#!/bin/bash

NUM_LEVELS=5
for i in $(seq -w 1 $NUM_LEVELS); do
    USER="level_$i"
    echo "Sterg utilizatorul $USER..."

    # Sterge utilizatorul si home-ul lui
    userdel -r "$USER" 2>/dev/null

    # Daca home-ul inca exista (in caz ca nu a fost sters automat), il stergi manual
    HOME_DIR="/home/$USER"
    if [[ -d "$HOME_DIR" ]]; then
        rm -rf "$HOME_DIR"
    fi
done

echo "Resetare completă."

