export HASS_TOKEN="$(get-secret hass_token)"
export HASS_SERVER="$(get-secret hass_server)"

toggle_lights() {
  for device_id in "switch.light_a_socket_1" "switch.light_b_socket_1"; do
    hass-cli service call homeassistant.toggle --arguments entity_id="$device_id" > /dev/null &
  done
}

(
  if ! flock -n 9; then
    echo "Cannot acquire lockfile, exiting."
    exit 1
  fi

  toggle_lights
) 9> /tmp/toggle-lights.lock
