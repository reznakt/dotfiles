spotify() {
  playerctl --player="spotify" "$@" 2> /dev/null
}

current_track() {
  echo "$(spotify metadata artist) - $(spotify metadata title)"
}

player_status=$(spotify status)

if [ "$player_status" = "Playing" ]; then
  current_track
elif [ "$player_status" = "Paused" ]; then
  echo " $(current_track)"
fi
