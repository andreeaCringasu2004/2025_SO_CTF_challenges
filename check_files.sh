#!/bin/bash

FILES=("note.txt" "debug.sh" "tmp.log")
HOME_DIR="/home/level_01"

for file in "${FILES[@]}"; do
    if [ -f "$HOME_DIR/$file" ]; then
        echo "$file există în $HOME_DIR"
    else
        echo "⚠️ $file NU există în $HOME_DIR"
    fi
done
