#!/bin/bash

cd "$HOME"

echo "Initializing submodules..."
yadm submodule update --recursive --init

