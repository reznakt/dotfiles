#!/usr/bin/env bash


if [ "$1" == "--help" ]; then
    echo "usage: stop <no_items>"
    exit 1
fi


du -hs ./* | sort -rh | head -n ${1:-10}

