#!/usr/bin/env bash
set -euo pipefail
kubectl rollout undo deployment/demo-hello -n demo
