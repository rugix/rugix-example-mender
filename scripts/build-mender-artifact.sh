#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
system="${1:?Usage: build-mender-artifact.sh SYSTEM}"
if ! command -v mender-artifact >/dev/null 2>&1; then
    echo "mender-artifact is required; install it or use the optional Nix shell." >&2
    exit 1
fi
version="${VERSION:-$(date +'%Y%m%d.%H%M')}"
output="${MENDER_ARTIFACT_OUTPUT:-build/$system/system.mender}"
mkdir -p "$(dirname -- "$output")"
exec mender-artifact write module-image \
    -n "${NAME:-Image} $version" \
    -t "${MENDER_ARTIFACT_DEVICE_TYPE:-rugix-generic-efi}" \
    -T rugix-bundle \
    -f "build/$system/system.rugixb" \
    -o "$output" \
    --software-name "${NAME:-Rugix Image}" \
    --software-version "$version"
