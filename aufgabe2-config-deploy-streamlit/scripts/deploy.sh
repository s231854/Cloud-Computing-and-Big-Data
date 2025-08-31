#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/deploy.sh [VERSION] [IP] [SSH_USER] [SSH_KEY] [SSH_PORT]
# Beispiele:
#   ./scripts/deploy.sh v1.0.0 141.72.13.88 ubuntu ~/.ssh/corne_key
#   ./scripts/deploy.sh                 # nimmt v1.0.0 + Terraform-Output (falls vorhanden)

VER="${1:-v1.0.0}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# 1) IP-Parameter hat Vorrang
APP_IP="${2:-}"

# 2) SSH-Parameter (optional)
SSH_USER="${3:-ubuntu}"
SSH_KEY="${4:-}"             # z. B. ~/.ssh/corne_key
SSH_PORT="${5:-22}"

# ~ im Keypfad expandieren (falls gesetzt)
if [[ -n "$SSH_KEY" ]]; then
  case "$SSH_KEY" in
    "~/"*) SSH_KEY="${HOME}/${SSH_KEY#~/}" ;;
  esac
fi

# 3) Falls keine IP übergeben, versuche Terraform – nur echte IPv4 akzeptieren
if [[ -z "${APP_IP}" ]]; then
  if pushd "$ROOT/terraform" >/dev/null 2>&1; then
    TF_OUT="$(terraform output -raw app_ip 2>/dev/null || true)"
    popd >/dev/null || true
    TF_OUT="$(echo -n "$TF_OUT" | tr -d '[:space:]')"
    if [[ "$TF_OUT" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
      APP_IP="$TF_OUT"
    fi
  fi
fi

# 4) Ohne IP abbrechen
if [[ -z "${APP_IP}" ]]; then
  echo "⚠️  Konnte app_ip nicht aus Terraform lesen. IP als 2. Parameter angeben."
  echo "Fehlende IP"
  exit 1
fi

# 5) Inventory schreiben
INV_DIR="$ROOT/ansible/inventory"
mkdir -p "$INV_DIR"

# Ansible-SSH-Args: HostKeyChecking aus & IdentitiesOnly an
SSH_ARGS="-o StrictHostKeyChecking=no -o IdentitiesOnly=yes"

HOST_LINE="$APP_IP ansible_host=$APP_IP ansible_port=$SSH_PORT ansible_user=$SSH_USER ansible_ssh_common_args='$SSH_ARGS'"
if [[ -n "$SSH_KEY" ]]; then
  HOST_LINE+=" ansible_ssh_private_key_file=$SSH_KEY"
fi

cat > "$INV_DIR/inventory.ini" <<INI
[app]
$HOST_LINE
INI

# 6) Playbooks ausführen
pushd "$ROOT/ansible" >/dev/null
# Hostkey-Checking global für diesen Lauf aus
ANSIBLE_HOST_KEY_CHECKING=False APP_VERSION="$VER" ansible-playbook -i inventory/inventory.ini deploy.yaml
ANSIBLE_HOST_KEY_CHECKING=False APP_VERSION="$VER" ansible-playbook -i inventory/inventory.ini verify.yaml
popd >/dev/null

echo "✅ Deploy abgeschlossen: Version $VER unter http://$APP_IP:8080/"
