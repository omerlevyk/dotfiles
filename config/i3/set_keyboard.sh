#!/bin/bash
set -euo pipefail

# Wait briefly until X is fully ready on login/restart
sleep 1

# English + Hebrew, Alt+Shift to toggle, Caps as Escape
setxkbmap -layout us,il -option 'caps:escape,grp:alt_shift_toggle'

# Keep a single LED helper instance
if ! pgrep -f "$HOME/.config/i3/lang_led.sh" >/dev/null 2>&1; then
  "$HOME/.config/i3/lang_led.sh" >/dev/null 2>&1 &
fi
