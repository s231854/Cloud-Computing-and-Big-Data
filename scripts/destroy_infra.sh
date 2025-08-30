#!/usr/bin/env bash
set -euo pipefail
for N in wk-2 wk-1 cp-1; do
  echo "[i] Deleting server $N if exists"
  openstack server delete --wait "$N" || true
done
echo "[ok] Done."
