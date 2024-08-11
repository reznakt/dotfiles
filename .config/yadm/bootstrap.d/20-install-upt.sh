#!/bin/bash


INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/sigoden/upt/main/install.sh"
INSTALL_DIR="$HOME/.local/bin"


if ! command -v upt &> /dev/null; then
  echo "Installing upt..."
  curl -fsSL "$INSTALL_SCRIPT_URL" | bash -s -- --to "$INSTALL_DIR"
fi

