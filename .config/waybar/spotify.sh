#!/bin/sh

spotify() {
  playerctl --player="spotify" "$@" 2> /dev/null
}

player_status=$(spotify status)

if [ "$player_status" = "Playing" ]; then
  echo "$(spotify metadata artist) - $(spotify metadata title)"
elif [ "$player_status" = "Paused" ]; then
  echo " $(spotify metadata artist) - $(spotify metadata title)"
fi

