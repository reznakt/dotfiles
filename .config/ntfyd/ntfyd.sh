#!/bin/bash

priority_to_urgency() {
  case "$1" in
    5) echo "critical" ;;
    4) echo "critical" ;;
    2) echo "low" ;;
    1) echo "low" ;;
    *) echo "normal" ;;
  esac
}

normalize_url() {
  if [[ ! "$1" =~ ^https?:// ]]; then
    echo "https://$1"
  else
    echo "$1"
  fi
}

dispatch_notification() {
  local event
  event=$(notify-send "${@}")
  
  if [ "$event" = "click" ]; then
    xdg-open "$(normalize_url "$click")"
  fi
}

if [ $# -ne 1 ]; then
  echo "usage: $0 <url>" 2>&1
  exit 1
fi

SUBSCRIPTION_URL="$1"

ntfy subscribe "$SUBSCRIPTION_URL" | while read -r line; do
  echo "$line" | jq
  event=$(echo "$line" | jq -r '.event')

  if [ "$event" != "message" ]; then
    continue
  fi

  title=$(echo "$line" | jq -r '.title')
  message=$(echo "$line" | jq -r '.message')
  priority=$(echo "$line" | jq -r '.priority')
  urgency=$(priority_to_urgency "$priority")
  click=$(echo "$line" | jq -r '.click')

  argv=(
    "$title"
    "$message"
    "--urgency=$urgency"
    "--app-name=ntfy.sh"
    "--icon=$(dirname -- "$0")/icon.ico"
  )

  if [ "$click" != "null" ]; then
    argv+=( "--action=click=Open '$click'" )
  fi

  dispatch_notification "${argv[@]}" &
done

