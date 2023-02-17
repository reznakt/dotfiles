#!/usr/bin/env bash

if [ ! -f "$1" ]; then
    echo "Error: file $1 not found"
    exit 
fi

out=${1%.c}

gcc -std=c99 -pedantic -Wall -Wextra -o $out $1 && ./$out
