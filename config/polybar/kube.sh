#!/bin/bash

export PATH=/usr/bin:/bin
export HOME=/home/omer
export KUBECONFIG=$HOME/.kube/config

CTX=$(kubectl config current-context 2>/dev/null)

if [ -n "$CTX" ]; then
  echo "󰠳 $CTX"
else
  echo "󰠳 0"
fi
