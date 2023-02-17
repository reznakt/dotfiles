#!/usr/bin/env bash
#            _                 _       
#   ___  ___| | ___   ___ __ _| |_ ___ 
#  / __|/ __| |/ _ \ / __/ _` | __/ _ \
#  \__ \ (__| | (_) | (_| (_| | ||  __/
#  |___/\___|_|\___/ \___\__,_|\__\___|
#                                      

. sclib

scset "SCERR"
. scinit

if [ -z "$1" ]; then
    scfatal "expected at least 1 argument"
fi

if scls | grep -q "^$1\$" && realpath $(which "$1" 2> /dev/null) 2> /dev/null; then
    exit 0
else
    scfatal "unable to locate script $1"
fi

