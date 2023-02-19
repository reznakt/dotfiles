#!/usr/bin/env bash
#             _                 _        _     _      
#    ___ ___ | | ___  _ __     | |_ __ _| |__ | | ___ 
#   / __/ _ \| |/ _ \| '__|____| __/ _` | '_ \| |/ _ \
#  | (_| (_) | | (_) | | |_____| || (_| | |_) | |  __/
#   \___\___/|_|\___/|_|        \__\__,_|_.__/|_|\___|
#                                                     


samples=(0 63 127 191 255)

for r in "${samples[@]}"; do
    for g in "${samples[@]}"; do
        for b in "${samples[@]}"; do
            printf '\e[0;%s8;2;%s;%s;%sm%03d;%03d;%03d ' "3" "$r" "$g" "$b" "$r" "$g" "$b"
        done 

        printf '\e[m\n'
    done

    printf '\e[m'
done

printf '\e[mReset\n'

