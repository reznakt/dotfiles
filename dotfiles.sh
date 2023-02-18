#!/usr/bin/env bash


FILEMAP=".filemap"
LOG=".dotfiles.log"


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


if ! [ -f "$FILEMAP" ]; then
    error "unable to find filemap at '$FILEMAP'"
fi


truncate --size 0 "$LOG"


rules=0
copied=0
skipped=0
failed=0


cat "$FILEMAP" | while read line; do
    if [ -z "$line" ]; then
        continue
    fi

    src=$(echo $line | cut -s -d " " -f 1)
    dst=$(echo $line | cut -s -d " " -f 2)

    if [ -z "$src" ] || [ -z "$dst" ]; then
        error "unsupported format in $FILEMAP ($line)"
    fi

    rules=$((rules + 1))

    src="${src/#\~/$HOME}"
    dst="${dst/#\~/$HOME}"

    if [ "$1" = "push" ]; then
        tmp="$dst"
        dst="$src"
        src="$tmp"
    fi

    if ! [ -f "$src" ] && ! [ -d "$src" ]; then
        skipped=$((skipped + 1))
        continue
    fi

    mkdir -p $(dirname "$dst") && files=$(cp -vbr "$src" "$dst")

    if [ $? = 0 ]; then
        echo "$files" >> "$LOG"
        nofiles=$(echo "$files" | wc -l)
        copied=$((copied + nofiles))
    else
        failed=$((failed + 1))
    fi

   echo -en "\rrules $rules  copied $copied  skipped $skipped  failed $failed"
done

echo;

