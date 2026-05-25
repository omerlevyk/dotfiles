#!/usr/bin/env bash

BASE="$HOME/.config/screenlayout"
WALLPAPER="$HOME/Pictures/gruvbox_astro.png"

lid_is_open() {
  for state_file in /proc/acpi/button/lid/*/state; do
    [ -r "$state_file" ] || continue
    grep -qi "open" "$state_file"
    return
  done

  return 0
}

if xrandr | grep -q "DP-1-1 connected"; then
  if lid_is_open; then
    "$BASE/home_and_laptop_layout.sh"
  else
    "$BASE/home_only_loyout.sh"
  fi
else
  "$BASE/laptop_only_layout.sh"
fi

~/.config/polybar/polybar_lanch.sh

# Re-apply wallpaper after monitor layout changes
feh --bg-scale "$WALLPAPER"
