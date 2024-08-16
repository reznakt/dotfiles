#!/bin/bash

PACKAGES="lsd topgrade"
TO_INSTALL=""

function has() {
  command -v "$1" &> /dev/null
}

function add_package() {
  package="$1"
  command="$2"

  if [ -z "$command" ]; then
    command="$package"
  fi

  if ! has "$command"; then
    TO_INSTALL="$TO_INSTALL $package"
  fi
}

for package in $PACKAGES; do
  if ! has "$package"; then
    add_package "$package"
  fi
done

# ripgrep is required for searching with telescope.nvim
if has "nvim"; then
  add_package "ripgrep" "rg"
fi

# minimal hyprland setup
if has "Hyprland"; then
  add_package "wofi"
  add_package "alacritty"
fi

if [ -n "$TO_INSTALL" ]; then
  echo "Installing missing packages..."
  sudo upt update
  sudo upt install -y "$TO_INSTALL"
fi

