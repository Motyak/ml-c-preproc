#!/bin/bash

FILE="$1"

[ "${FILE##*.}" == "mlp" ] || {
    >&2 echo "Invalid file extension: \`${FILE##*.}\`"
    exit 1
}

[ "$FILE" -nt "${FILE%.mlp}.ml" ] || {
    >&2 echo "nothing to do"
    exit 0
}

cat /dev/null > "${FILE%.mlp}.ml"
cpp -w -P "$FILE" | perl -pe 's/^\s+$//gm' >> "${FILE%.mlp}.ml"
