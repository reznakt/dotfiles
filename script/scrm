#!/usr/bin/env bash
#                           
#   ___  ___ _ __ _ __ ___  
#  / __|/ __| '__| '_ ` _ \ 
#  \__ \ (__| |  | | | | | |
#  |___/\___|_|  |_| |_| |_|
#                           

. sclib
. scinit

if isunset "$1"; then
    scfatal "expected at least 1 argument"
fi

SCRIPT=$(sclocate "$1")

if [ "$?" -ne "0" ]; then
    scfatal "unable to locate script $1"
fi

echo -n "Move script $1 to trash (y/n)? "
read CHOICE

case "$CHOICE" in
    Y|y)
        mv "$SCRIPT" "$(scwd)/trash"
    ;;

    *)
        scinfo "Aborting..."
        exit 1
    ;;
esac

