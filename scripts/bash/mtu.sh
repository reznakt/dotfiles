#!/usr/bin/env bash
#             _         
#   _ __ ___ | |_ _   _ 
#  | '_ ` _ \| __| | | |
#  | | | | | | |_| |_| |
#  |_| |_| |_|\__|\__,_|
#                       

. sclib
. scinit

if isunset "$1"; then
    scfatal "expected at least 1 argument"
fi

for i in {1..65535..1}; do
	if ! ping -M do -s "$i" -c 1 -W 5 "$1" &> /dev/null; then
        echo $(date +"%Y-%m-%d %H:%M:%S") $(($i + 28 - 1))
		break
	fi
done

