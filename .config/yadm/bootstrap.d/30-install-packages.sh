#!/bin/bash

PACKAGES="lsd topgrade"
TO_INSTALL=""

for package in $PACKAGES; do
  if ! command -v $package &> /dev/null; then
    TO_INSTALL="$TO_INSTALL $package"
  fi
done

if [ -n "$TO_INSTALL" ]; then
  echo "Installing missing packages..."
  sudo upt update
  sudo upt install -y $TO_INSTALL
fi

