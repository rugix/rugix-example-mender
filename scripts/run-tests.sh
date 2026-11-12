#!/usr/bin/env bash

set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

if [ ! -e keys/id_rsa ]; then
    bash scripts/generate-test-keys.sh
fi

# Create a dummy .env for testing (no real Mender server connection needed).
if [ ! -e .env ]; then
    echo 'MENDER_TENANT_TOKEN="test-dummy-token"' > .env
fi

mkdir -p build

./run-bakery bake image test-mender-efi-arm64
./run-bakery bake bundle --disable-compression test-mender-efi-arm64

bash scripts/build-mender-artifact.sh test-mender-efi-arm64

./run-bakery test
