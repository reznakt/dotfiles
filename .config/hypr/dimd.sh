#!/bin/bash

set -e

SLEEP=0.01
STEP=2
MIN_VALUE=10

dim() {
  local brightness
  brightness=$(brightnessctl get)

  while true; do
    brightness=$((brightness - STEP))

    if [ "$brightness" -le $MIN_VALUE ]; then
      break
    fi

    brightnessctl set "$brightness"
    sleep $SLEEP
  done
}

dim_pid=""
brightness=""

dim_start() {
  dim_stop
  brightness=$(brightnessctl get)
  dim &
  dim_pid=$!
}

dim_stop() {
  kill -KILL "$dim_pid" &> /dev/null || true
  dim_pid=""

  if [ -n "$brightness" ]; then
    brightnessctl set "$brightness"
  fi
}

trap dim_start USR1
trap dim_stop USR2 EXIT

while true; do
  wait || true
done

