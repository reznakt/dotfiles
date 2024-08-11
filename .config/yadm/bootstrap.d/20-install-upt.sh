#!/bin/bash

UPT_TAG="v0.8.0"
INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/sigoden/upt/$UPT_TAG/install.sh"
INSTALL_DIR="$HOME/.local/bin"

if ! command -v upt &> /dev/null; then
  echo "Installing upt..."
  curl -fsSL "$INSTALL_SCRIPT_URL" | bash -s -- --to "$INSTALL_DIR"
fi

