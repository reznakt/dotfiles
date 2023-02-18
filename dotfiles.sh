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


if ! [ -f "$FILEMAP" ]; then
    error "unable to find filemap at '$FILEMAP'"
fi


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

    mkdir -p $(realpath $(basename "$dst")) && nofiles=$(cp -vbr "$src" "$dst" | wc -l)

    if [ $? = 0 ]; then
        copied=$((copied + nofiles))
    else
        failed=$((failed + 1))
    fi

   echo -en "\rrules $rules  copied $copied  skipped $skipped  failed $failed"
done

echo;

