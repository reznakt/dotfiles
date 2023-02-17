if [ -d $1 ]; then
    du -h $1 | tail -n 1 | cut -d $'\t' -f 1
    exit 0
fi

if [ -f $1 ]; then
    cat $1 | wc -c | numfmt --to=si
    exit 0
fi

echo "Error: no such file or directory: '$1'"
exit 1
