#!/bin/bash

set -u

if [ $# -lt 2 ] ; then
    echo "$0 <image.jpg> <code.c> [height]"
    exit
fi

command -v jp2a >/dev/null 2>&1 || { echo >&2 "Requires jp2a."; exit 1; }

IMAGE=$1
CODE=$2
HEIGHT=${3:-40}

# some character that does not occur (much) in CODE
FILLER="'"

TMPFILE=$(mktemp)

function cleanup()
{
    rm "${TMPFILE}"
}

trap cleanup EXIT

jp2a --chars="${FILLER} " --height="${HEIGHT}" "${IMAGE}" > "${TMPFILE}"
while IFS= read -n1 c ; do
    # escape the sed substitution command delimiter
    if [ "${c}" = '/' ] ; then
        c="\\${c}"
    fi
    sed -ie "0,/${FILLER}/ s/${FILLER}/${c}/" "${TMPFILE}"
    # squash consecutive spaces into one
done < <(tr '\n' ' ' < "${CODE}" | sed -e 's/ \+/ /g')

cat "${TMPFILE}"
