#!/usr/bin/env bash

set -euo pipefail

if [ ! -e keys/id_rsa ]; then
    ./generate-test-keys.sh
fi

# Create a dummy .env for testing (no real Mender server connection needed).
if [ ! -e .env ]; then
    echo 'MENDER_TENANT_TOKEN="test-dummy-token"' > .env
fi

mkdir -p build

./run-bakery bake image test-mender-efi-arm64
./run-bakery bake bundle --disable-compression test-mender-efi-arm64

# Run mender-artifact inside a container to avoid host library issues.
VERSION=$(date +'%Y%m%d.%H%M')
podman run --rm \
    -v "$(pwd)/build":/build \
    docker.io/library/debian:bullseye-slim \
    bash -c "
        apt-get update -qq && apt-get install -y -qq wget >/dev/null 2>&1
        wget -q -O /usr/local/bin/mender-artifact \
            https://downloads.mender.io/mender-artifact/4.0.0/linux/mender-artifact
        chmod +x /usr/local/bin/mender-artifact
        mender-artifact write module-image \
            -n 'Image ${VERSION}' \
            -t rugix-generic-efi \
            -T rugix-bundle \
            -f /build/test-mender-efi-arm64/system.rugixb \
            -o /build/test-mender-efi-arm64/system.mender \
            --software-name 'Rugix Image' \
            --software-version '${VERSION}'
    "

./run-bakery test
