if [ "$#" -ne 1 ]; then
    echo "usage: incsort FILE"
    exit 1
fi

cat $1 | grep "^#include <.*>$" | awk '{ print length(), $0 | "sort -n" }' | cut -d " " -f 2-
