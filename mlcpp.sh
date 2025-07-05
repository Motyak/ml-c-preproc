#!/bin/bash
set -o errexit
set -o pipefail
# set -o xtrace #debug

if [ "$1" == -o ]; then
    FILEOUT="$2"
    [[ "$FILEOUT" =~ ^-$ ]] && FILEOUT="/dev/stdout"
    FILEIN="$3"
    ARGS="${@:4:$#-1}"
else
    FILEIN="$1"
    FILEOUT="${1%.mlp}.ml"
    ARGS="${@:2:$#-1}"
fi

[[ "$FILEIN" =~ ".mlp"$ ]] || {
    >&2 echo "Invalid file extension: \`${FILEIN##*.}\`"
    exit 1
}

cpp -w $ARGS "$FILEIN" \
    | perl -0pe 's/^package main\n.*?\n# /# /gms' \
    | perl -pe 's/^package [^ ]+$//gm' \
    | perl -pe 's/^# \d.*\n//gm' \
    | perl -ne 'print unless s/^ +$//' > "$FILEOUT"
