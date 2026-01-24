#!/bin/bash

DEFAULT_DEV=$(ip route |
  awk '/^default/ {print $5, $NF}' |
  sort -k2 -n |
  head -n1 |
  awk '{print $1}')

case "$DEFAULT_DEV" in
eno* | enp* | eth*)
  echo ""
  ;;
wlo* | wlp* | wl*)
  echo ""
  ;;
*)
  echo ""
  ;;
esac
