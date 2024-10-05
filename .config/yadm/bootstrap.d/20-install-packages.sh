#!/bin/bash

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

add_package "lsd"
add_package "topgrade"

# ripgrep is required for searching with telescope.nvim
if has "nvim"; then
  add_package "ripgrep" "rg"
fi

# minimal hyprland setup
if has "Hyprland"; then
  add_package "wofi"
  add_package "alacritty"
  add_package "Waybar" "waybar"
  add_package "inotify-tools" "inotifywatch"
  add_package "brightnessctl"
  add_package "hyprlock"
  add_package "hypridle"
  add_package "grim"
  add_package "slurp"
  add_package "wl-clipboard" "wl-copy"
fi

if [ -n "$TO_INSTALL" ]; then
  echo "Installing missing packages..."
  sudo upt update
  sudo upt install -y "$TO_INSTALL"
fi

