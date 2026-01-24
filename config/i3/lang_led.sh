#!/bin/bash

while true; do
  layout=$(setxkbmap -query | grep layout | awk '{print $2}' | cut -d, -f1)

  if [ "$layout" = "il" ]; then
    xset led named "Caps Lock"
  else
    xset -led named "Caps Lock"
  fi

  sleep 0.5
done
