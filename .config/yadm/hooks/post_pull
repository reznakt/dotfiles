#!/bin/bash

set -e

ALF_BINARY="$HOME/.submodules/alf/alf"

if [ -z "$YADM_HOOK_EXIT" ]; then
  YADM_HOOK_EXIT=0
fi

if [ "$YADM_HOOK_EXIT" -ne 0 ]; then
  echo "Skipping $0 hook because of previous errors"
  exit $YADM_HOOK_EXIT
fi

echo "Generating aliases..."
cd "$HOME/.config/alf"
"$ALF_BINARY" save

