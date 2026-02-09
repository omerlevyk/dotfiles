#!/bin/bash

export PATH=/usr/bin:/bin
export HOME=/home/omer
export KUBECONFIG=$HOME/.kube/config

# if there is no cluster connected
kubectl cluster-info >/dev/null 2>&1 || {
  echo "󰠳 0"
  exit 0
}

# counting the running pod count
PODS=$(kubectl get pods --all-namespaces \
  --field-selector=status.phase=Running \
  --no-headers 2>/dev/null | wc -l)

echo "󰠳 $PODS"
