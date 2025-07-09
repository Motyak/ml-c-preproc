#!/bin/bash
set -o errexit
set -o pipefail
# set -o xtrace #debug

# protection against corrupted output file
trap '[ -f "$FILEOUT" ] && rm -f "$FILEOUT"' ERR

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

# for this to work, we align output file last modif date
# ..with input file's, at the time of preprocessing
[ -f "$FILEOUT" ] && [ "$FILEOUT" -nt "$FILEIN" ] && {
    # protection against losing data
    >&2 echo "Output file has been updated, are you sure you want to overwrite it ?"
    >&2 echo -n "confirm?(Y/n) >"
    read confirm
    [[ "$confirm" =~ n|N ]] && { >&2 echo "aborted"; exit 0; }
}

# first pass is just for printing errors, if any
>/dev/null cpp -w "$FILEIN"

# escape backslash-newline (otherwise interpreted as continued line by cpp)
escaped="$(perl -pe 's|\\\n|\\/**/\n|gm' "$FILEIN")"

cpp -w $ARGS <<< "$escaped" \
    | perl -0pe 's/^package main\n.*?\n# /# /gms' \
    | perl -pe 's/^package (\S+)\n/"package $1"\n/gm' \
    | perl preprocess_cpp_linemarkers.pl > "$FILEOUT"

[ -f "$FILEOUT" ] && touch -r "$FILEIN" "$FILEOUT"

true
