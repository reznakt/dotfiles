#!/usr/bin/env bash


FILEMAP=".filemap"


function error() {
    echo "error: $1" 1>&2
    exit 1
}


if [ $# = 0 ] || [ $# -ge 3 ]; then
    error "illegal number of arguments ($#)"
fi


if ! [ "$1" = "pull" ] && ! [ "$1" = "push" ]; then
    error "illegal option '$1'"
fi


cat "$FILEMAP" | while read line; do
    if [ -z "$line" ]; then
        continue
    fi

    src=$(echo $line | cut -s -d " " -f 1)
    dst=$(echo $line | cut -s -d " " -f 2)

    if [ -z "$src" ] || [ -z "$dst" ]; then
        error "unsupported format in $FILEMAP ($line)"
    fi

    src="${src/#\~/$HOME}"
    dst="${dst/#\~/$HOME}"

    case "$1" in
        "pull")
            if ! [ -f "$src" ] && ! [ -d "$src" ]; then
                continue
            fi

            mkdir -p $(realpath $(basename "$dst"))
            cp -vbr "$src" "$dst"
            ;;
        "push")
            if ! [ -f "$dst" ] && ! [ -d "$dst" ]; then
                continue
            fi

            mkdir -p $(realpath $(basename "$src"))
            cp -vbr "$dst" "$src"
    esac
done

