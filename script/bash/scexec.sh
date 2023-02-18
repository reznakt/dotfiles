#!/usr/bin/env bash

. sclib

if [ -z "$SCRIPT" ]; then
    scfatal "attempted standalone execution without a scriptfile"
fi

PY_INTERPS="/packages/run.64/python3-3.9.6/bin/python /usr/bin/python3"

for interp in $PY_INTERPS; do
    if [ -f $interp ]; then
        eval "$interp  $(scwd)/$SCRIPT $@"
        exit 0
    fi
done

scfatal "no python3 interpreter found"

