#!/bin/sh

# get list of updates and extract only package names (first column)
pkgs=$(xbps-install -nuM | awk '{print $1}')
pkg_count=$(echo "$pkgs" | wc -w)

if [ "$pkg_count" -eq 0 ]; then
  exit 1
fi

# convert list of packages to a single line with '\n' instead of actual newlines
# make sure to remove the last newline
pkg_list=$(echo "$pkgs" | awk '{print}' ORS='\\n' | sed '$s/..$//')

# convert everything to JSON
# make sure it's all on a single line because the Waybar parser is weird
(cat <<EOF
{
  "text": "$pkg_count",
  "tooltip": "$pkg_list"
}
EOF
) | tr '\n' ' '
