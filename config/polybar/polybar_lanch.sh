#!/usr/bin/env bash

killall -q polybar

while pgrep -x polybar >/dev/null; do
  sleep 0.5
done

for m in $(polybar --list-monitors | cut -d":" -f1); do
  MONITOR=$m polybar main &
  >/dev/null
done
