#!/bin/bash

LEVEL=$1
USER_INPUT="$2"
FLAG_FILE="flags/${LEVEL}.flag"

if [[ ! -f "$FLAG_FILE" ]]
then
	echo "Flag-ul pentru acest nivel nu exista!"
	exit 1
fi

REAL_FLAG=$(cat "$FLAG_FILE")

if [[ "$USER_INPUT" == "$REAL_FLAG" ]]; then
    echo " Flag corect! Felicitari, ai trecut nivelul $LEVEL!"
    # pt incrementarea scorului
else
    echo " Flagul gasit este incorect. Incearca din nou!"
fi
