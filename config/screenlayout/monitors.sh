#!/usr/bin/env bash

BASE="$HOME/.config/screenlayout"

# check connected monitors
CONNECTED=$(xrandr | grep " connected" | cut -d" " -f1)

# if office monitor
if echo "$CONNECTED" | grep -q "DP-1-3"; then
  "$BASE/office_monitor_layout.sh"

# if home monitor
elif echo "$CONNECTED" | grep -q "DP-1-1"; then
  "$BASE/home_monitor_layout.sh"

# laptop only
else
  xrandr --output eDP-1 --auto --primary
fi
