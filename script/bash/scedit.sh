#!/usr/bin/env bash

. sclib


scset "SCCHWD"
. scinit

if [ -z "$1" ]; then
    scfatal "expected at least 1 argument"
fi

SCRIPT=$(sclocate "$1")

if [ "$?" -ne "0" ]; then
    scfatal "unable to locate script $1"
fi

if [ -n "$EDITOR" ]; then
    $EDITOR $SCRIPT
else
    nano $SCRIPT
fi

echo -en "\033[3 q"

