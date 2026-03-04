#!/usr/bin/env bash

BASE="$HOME/.config/screenlayout"

# if home monitor
if xrandr | grep "DP-1-1 connected" >/dev/null; then
  "$BASE/home_monitor_layout.sh"
  ~/.config/polybar/polybar_lanch.sh
  # if projector
elif xrandr | grep "DP-3 connected" >/dev/null; then
  "$BASE/projector_layout.sh"
  ~/.config/polybar/polybar_lanch.sh
else # laptop only
  "$BASE/laptop_only_layout.sh"
fi
