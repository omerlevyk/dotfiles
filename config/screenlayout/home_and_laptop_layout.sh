#!/bin/sh

xrandr \
  --output eDP-1 --mode 1920x1080 --rate 60 --primary --pos 0x1080 \
  --output DP-1-1 --mode 1920x1080 --rate 120 --pos 0x0 \
  --output DP-1 --off \
  --output HDMI-1 --off \
  --output DP-2 --off \
  --output HDMI-2 --off \
  --output DP-3 --off \
  --output DP-1-2 --off \
  --output DP-1-3 --off
