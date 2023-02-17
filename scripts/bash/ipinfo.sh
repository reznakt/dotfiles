#!/usr/bin/env bash

curl -s "ipinfo.io" | tail -n +2 | head -n -2 | cut -d " " -f 3- | tr -d "\"" | sed "s/.$//"

