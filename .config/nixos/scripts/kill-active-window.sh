ACTIVE_WINDOW_CLASS=$(hyprctl activewindow -j | jq -r '.class')

if [ "$ACTIVE_WINDOW_CLASS" = "thunderbird" ]; then
    hyprctl dispatch togglespecialworkspace mail
else
    hyprctl dispatch killactive
fi
