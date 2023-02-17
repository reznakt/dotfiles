#!/usr/bin/env bash

. sclib

scset "SCCHWD"
. scinit

cd "bash"

if [ -z "$1" ]; then
    scfatal "expected at least 1 argument"
fi

SCPATH="$1.sh"

if [ -f "$SCPATH" ]; then
    scfatal "script $1 already exists, use scedit"
fi


if ! command -v "pyfiglet" > /dev/null; then
    scwarn "pyfiglet not found"
fi

scinfo "generating skeleton..."
{
    cat .sctemplate
    pyfiglet "$1" | head -n -1 | ts "# "
    echo; echo;
} > $SCPATH 2> /dev/null

scinfo "updating scripts..."
scupdate > /dev/null

scedit $1

