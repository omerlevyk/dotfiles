#!/bin/bash

DEFAULT_DEV=$(ip route |
  awk '/^default/ {print $5, $NF}' |
  sort -k2 -n |
  head -n1 |
  awk '{print $1}')

case "$DEFAULT_DEV" in
eno* | enp* | eth*)
  echo " "
  ;;
wlo* | wlp* | wl*)
  SSID=$(iwgetid -r 2>/dev/null | cut -c1-12)

  if [ -n "$SSID" ]; then
    echo "  $SSID"
  else
    echo " "
  fi
  ;;
*)
  echo ""
  ;;
esac
