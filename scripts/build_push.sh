#!/usr/bin/env bash
set -euo pipefail
REGISTRY=${REGISTRY:-141.72.13.194:32000}
NAME=${NAME:-demo-hello}
VERSION=${VERSION:-v0.1.0}
cd app/fastapi
docker build -t ${REGISTRY}/${NAME}:${VERSION} .
docker push ${REGISTRY}/${NAME}:${VERSION}
