#!/usr/bin/env bash

echo;
curl -s wttr.in | head -n -1 | ts "    "

