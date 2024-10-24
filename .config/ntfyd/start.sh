#!/bin/sh

CONFIG_DIR="$HOME/.config/ntfyd"

trap 'trap - TERM && kill -- -$$' INT TERM EXIT

while read -r url; do
  if [ -n "$url" ]; then
    echo "$url"
    "$CONFIG_DIR/ntfyd.sh" "$url" &
  fi
done < "$CONFIG_DIR/config"

while true; do
  sleep 1
  wait
done
