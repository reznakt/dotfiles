#!/bin/bash

REMOTE_URL=$(yadm remote get-url origin)

if echo "$REMOTE_URL" | grep --quiet "https://"; then
  REPO_IDENTIFIER=$(echo "$REMOTE_URL" | sed -e "s#https://github.com/##" -e "s/\.git$//")
  SSH_URL="git@github.com:$REPO_IDENTIFIER.git"

  echo "Switching yadm remote to SSH: $SSH_URL"
  yadm remote set-url origin "$SSH_URL"
fi

