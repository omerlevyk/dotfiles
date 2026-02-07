#!/bin/bash

if ! command -v docker >/dev/null 2>&1; then
  exit 0
fi

if ! docker info >/dev/null 2>&1; then
  echo "󰡨 ✗"
  exit 0
fi

COUNT=$(docker ps -q | wc -l)
echo "󰡨 $COUNT"
