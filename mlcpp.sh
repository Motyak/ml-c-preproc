#!/bin/bash
set -o errexit
set -o pipefail

FILE="$1"

[ "${FILE##*.}" == "mlp" ] || {
    >&2 echo "Invalid file extension: \`${FILE##*.}\`"
    exit 1
}

cat /dev/null > "${FILE%.mlp}.ml"
cpp -w "$FILE" \
    | perl -0pe 's/^package main\n.*?\n# /# /gms' \
    | perl -pe 's/^package [^ ]+$//gm' \
    | perl -pe 's/^# \d.*\n//gm' \
    | perl -ne 'print unless s/^ +$//' >> "${FILE%.mlp}.ml"
