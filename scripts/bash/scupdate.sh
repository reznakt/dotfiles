#!/usr/bin/env bash

. sclib

scset "SCCHWD"
. scinit

src_dir="src"
min_dir="min"
bash_dir="bash"
run_path="scexec"

if [ ! -d $src_dir ] || [ $(ls -A $src_dir/*.py | wc -l) == 0 ]; then
    scfatal "no source files found $src_dir"
fi

for f in $src_dir/*.py; do
    echo "Minifying file $f..."

    fname=$(echo "$f" | cut -d "/" -f "2-")
    size1=$(cat $f | wc -c)
    
    python3 -m python_minifier $f > $min_dir/$fname

    if [ ! -d $min_dir ]; then
        mkdir $min_dir
    fi
    
    size2=$(cat $min_dir/$fname | wc -c)
    diff=$(echo "scale=2 ; 100 * (1 - ($size2 / $size1))" | bc)

    echo "Shrunk file size from $size1 bytes to $size2 bytes ($diff %)"
    echo "Copied to $min_dir/$fname"

    sourcefile="${fname%.py}"
    printf "#!/usr/bin/env bash\n\n# Scriptfile for $fname created at $(date "+%Y/%m/%d %H:%M:%S")\n\n\nSCRIPT=\"$min_dir/$fname\"\nsource $run_path\n\n" > "$sourcefile"
    chmod +x $sourcefile

    echo "Created scriptfile"
    echo
done

for f in $bash_dir/*.sh; do
    fname=$(basename -- "$f")
    fname="${fname%.*}"

    ln -sf $f $fname
    chmod +x $fname

    echo "Created symlink $fname -> $f"
done

for f in $(find . -xtype l); do
    rm $f
    echo "Removed broken symlink $f"
done

