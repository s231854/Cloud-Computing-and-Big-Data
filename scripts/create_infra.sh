#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-Ubuntu 22.04 2025-01}"
FLAVOR="${FLAVOR:-mb1.medium}"
EXT_NET="${EXT_NET:-DHBW}"
KEY="${KEY:-cornelius_mueller}"
NET_NAME="${NET_NAME:-k8s-net}"
SG_NAME="${SG_NAME:-k8s-sg}"
USER_DATA="${USER_DATA:-$HOME/cloud-bigdata-aufgabe3/infra/openstack/cloud-init.yaml}"

echo "[i] Using IMAGE='$IMAGE' FLAVOR='$FLAVOR' EXT_NET='$EXT_NET' KEY='$KEY'"

SG_ID=$(openstack security group show -f value -c id "$SG_NAME")
NET_ID=$(openstack network show -f value -c id "$NET_NAME")

# Create servers
for NAME in cp-1 wk-1 wk-2; do
  echo "[i] Creating server $NAME"
  openstack server create --image "$IMAGE" --flavor "$FLAVOR" \
    --key-name "$KEY" --security-group "$SG_ID" --nic net-id="$NET_ID" \
    --user-data "$USER_DATA" "$NAME"
done

# Floating IP für wk-1
FIP=$(openstack floating ip create "$EXT_NET" -f value -c floating_ip_address)
openstack server add floating ip wk-1 "$FIP"
echo "[ok] Floating IP attached to wk-1: $FIP"

openstack server list
