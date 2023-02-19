#!/usr/bin/env bash

. sclib

if isset $SCCHWD; then
    SCRIPT_DIR=$(scwd)

    if [ ! -d "$SCRIPT_DIR" ]; then
        scfatal "invalid path obtained by scwd"
    fi

    cd $SCRIPT_DIR
fi

if isset $SCERR; then
    set -e
fi

if isset $SCDEBUG; then
    set -x
fi

