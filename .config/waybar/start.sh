#!/bin/bash

trap "killall waybar" EXIT

while true; do
  waybar &
  inotifywait -r -e create,modify,delete "$HOME/.config/waybar/"
  killall waybar
done

