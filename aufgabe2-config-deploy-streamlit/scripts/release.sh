#!/usr/bin/env bash
set -euo pipefail
VER="${1:-v1.0.0}"
cd "$(dirname "$0")/.."/terraform

terraform init -input=false
terraform apply -auto-approve -var-file=../terraform.tfvars
