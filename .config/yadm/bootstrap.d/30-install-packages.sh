#!/bin/bash

PACKAGES="lsd topgrade"
TO_INSTALL=""

function has() {
  command -v $1 &> /dev/null
}

for package in $PACKAGES; do
  if ! has $package; then
    TO_INSTALL="$TO_INSTALL $package"
  fi
done

# ripgrep is required for searching with telescope.nvim
if has "nvim" && ! has "rg"; then
  TO_INSTALL="$TO_INSTALL ripgrep"
fi

if [ -n "$TO_INSTALL" ]; then
  echo "Installing missing packages..."
  sudo upt update
  sudo upt install -y $TO_INSTALL
fi

