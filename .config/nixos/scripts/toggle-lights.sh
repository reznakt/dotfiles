set -e

SECRETS_FILE="${HOME}/.config/nixos/secrets/home-assistant.yaml"
HASS_TOKEN="$(sops --decrypt --extract '["hass-token"]' $SECRETS_FILE)"
HASS_SERVER="$(sops --decrypt --extract '["hass-server"]' $SECRETS_FILE)"

export HASS_TOKEN
export HASS_SERVER

toggle_lights() {
  pids=""

  for device_id in "switch.light_a_socket_1" "switch.light_b_socket_1"; do
    hass-cli service call homeassistant.toggle --arguments entity_id="$device_id" > /dev/null &
    pids="$pids $!"
  done

  wait $pids
}

(
  if ! flock -n 9; then
    echo "Cannot acquire lockfile, exiting."
    exit 1
  fi

  toggle_lights
) 9> /tmp/toggle-lights.lock
