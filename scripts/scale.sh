#!/usr/bin/env bash
set -euo pipefail
REPLICAS=${1:-5}
kubectl scale deployment demo-hello -n demo --replicas=${REPLICAS}
