#!/usr/bin/env bash

. sclib

scset "SCCHWD"
. scinit

cd "bash"

if [ ! -f .scdeps ]; then
    touch .scdeps
    exit 0
fi

export SCDEPS=$(cat .scdeps)

for package in $SCDEPS; do
    echo "Installing prerequisite $package..."
    sudo apt -qq install $package
    echo;
done

