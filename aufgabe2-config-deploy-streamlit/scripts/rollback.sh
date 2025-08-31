#!/usr/bin/env bash
set -euo pipefail
"$(dirname "$0")/deploy.sh" "${1:-v1.0.0}" "${2:-}"
