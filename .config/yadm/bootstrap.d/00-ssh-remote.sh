#!/bin/bash

REMOTE_URL="git@github.com:reznakt/dotfiles.git"

echo "Switching yadm remote to SSH: $REMOTE_URL"
yadm remote set-url origin $REMOTE_URL

