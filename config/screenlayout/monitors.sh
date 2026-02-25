#!/usr/bin/env bash

BASE="$HOME/.config/screenlayout"

# if home monitor
if xrandr | grep "DP-1-1 connected" >/dev/null; then
  ~/.config/screenlayout/home_monitor_layout.sh
  ~/.config/polybar/polybar_lanch.sh
else # laptop only
  ~/.config/screenlayout/laptop_only_layout.sh
fi
