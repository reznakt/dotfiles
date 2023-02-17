#!/usr/bin/env bash


FILEMAP=".filemap"


cat "$FILEMAP" | while read line; do
    if [ -z "$line" ]; then
        continue
    fi

    src=$(echo $line | cut -s -d " " -f 1)
    dst=$(echo $line | cut -s -d " " -f 2)

    if [ -z "$src" ] || [ -z "$dst" ]; then
        echo "error: unsupported format in $FILEMAP ($line)" 1>&2
        exit 1
    fi

    src="${src/#\~/$HOME}"
    dst="${dst/#\~/$HOME}"

    if ! [ -f "$src" ]; then
        continue
    fi

    #cp "$dst" "$dst.bak" || true
    cp -vb "$src" "$dst"

done

