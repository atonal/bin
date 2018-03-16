#!/bin/bash

set -euo pipefail

set -x

usage()
{
    echo "Print the version number as follows:"
    echo
    echo "- If HEAD is on <latest tag>, outputs: <latest tag>"
    echo "  e.g. 1.0.2"
    echo
    echo "- If HEAD is further than <latest tag>, outputs:"
    echo "  <latest tag>-<num of commits after latest tag>-g<SHA-1 of HEAD>"
    echo "  e.g. 1.0.2-14-g053a464bc44a86f8ad0d096548c8e5f337bab154"
    echo
    echo "- If there are no tags, prints the full SHA-1 hash of HEAD"
    echo "  e.g. g053a464bc44a86f8ad0d096548c8e5f337bab154"
    echo
    echo "If the working tree contains changes, appends \"-dirty\" to the output"
    echo
    echo "usage: $0 [options] [pattern]"
    echo
    echo "valid options:"
    echo "    -s, --sha-only  Print only the full SHA-1 hash of HEAD"
    echo "    -h, --help      Show this message"
    echo
}

OPTS=$(
    getopt \
        --options sh \
        --long sha-only \
        --long help \
        --name "$0" \
        -- "$@"
)

eval set -- "${OPTS}"

sha_only=false

while true; do
    case "$1" in
        -s|--sha-only)
            sha_only=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal error!" 2>&1
            exit 1
            ;;
    esac
done

if [[ "$#" -gt 0 ]]; then
    pattern="$1"
    shift
fi


if [ "${sha_only}" = true ]; then
    cmd=(git rev-parse HEAD)
else

    cmd=(
        git describe
        --always # fall back to git hash of HEAD if no tags found
        --dirty # append -dirty if workspace is not clean
        --abbrev=40 # use full hash
        --tags # all tags, includes non-annotated tags (remove?)
        ${pattern:+--match ${pattern}}
    )
fi

"${cmd[@]}"
