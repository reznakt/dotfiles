#!/usr/bin/env bash

. sclib

if [ -z $1 ]; then
    scfatal "expected at least 1 argument"
fi

python3 "$HOME/Documents/Projects/pb071-tests/$1/main.py"
exit $?
