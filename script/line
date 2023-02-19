#!/usr/bin/env bash

. sclib

if [ "$1" = "-n" ] && [ -n "$2" ] ; then
    if [ "$2" -le "0" ]; then
        scfatal "error: argument 'n' must be positive"
    fi

    sed -n "${2}p"

else
    echo "usage: line -n [NUM]"
    exit 1
fi

