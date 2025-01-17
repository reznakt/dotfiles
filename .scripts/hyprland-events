#!/bin/sh

socket_path="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

socat -U - UNIX-CONNECT:"$socket_path" | while read -r line; do
  # event list: https://wiki.hyprland.org/IPC/#events-list
  case "$line" in
    activewindow*) pkill -RTMIN+1 waybar ;;
  esac
done

