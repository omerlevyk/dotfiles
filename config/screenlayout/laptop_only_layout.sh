#!/bin/sh

# Laptop only
xrandr --output eDP-1 \
  --mode 1920x1080 \
  --rate 60 \
  --primary \
  --pos 0x0 \
  --rotate normal

# Turn everything else off
for output in DP-1 HDMI-1 DP-2 HDMI-2 DP-3 DP-1-1 DP-1-2 DP-1-3; do
  xrandr --output "$output" --off
done
