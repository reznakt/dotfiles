#!/bin/sh

UPT_VERSION="0.8.0"
UPT_URL="https://raw.githubusercontent.com/sigoden/upt/v$UPT_VERSION/install.sh"
INSTALL_DIR="$HOME/.local/bin"

get_upt_version() {
  "$INSTALL_DIR/upt" --help 2>&1 | sed -n "s/^Upt version: //p"
}

install_upt () {
  curl -fsSL "$UPT_URL" | bash -s -- --to "$INSTALL_DIR" --tag "v$UPT_VERSION" "$@"
  chmod +x "$INSTALL_DIR/upt"
}

if ! [ -f "$INSTALL_DIR/upt" ]; then
  echo "Installing upt ($UPT_VERSION)..."
  install_upt
elif ! [ "$(get_upt_version)" = "$UPT_VERSION" ]; then
  echo "Upgrading upt ($(get_upt_version) -> $UPT_VERSION)..."
  install_upt --force
fi
