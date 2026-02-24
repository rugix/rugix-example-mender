#!/usr/bin/env bash

set -euo pipefail

# Add service user for remote Mender terminal.
useradd -U -m -s /bin/zsh service

# Install Mender configuration files.
mkdir -p /etc/mender
install -D -m 644 "${RECIPE_DIR}/files/mender.conf" -t /etc/mender
install -D -m 644 "${RECIPE_DIR}/files/mender-connect.conf" -t /etc/mender
install -D -m 644 "${RECIPE_DIR}/files/device_type" -t /etc/mender

# Inject Mender tenant token from the secret environment.
echo ".env" >> "${LAYER_REBUILD_IF_CHANGED}"
. "${RUGIX_PROJECT_DIR}/.env"
sed -i "s@%%MENDER_TENANT_TOKEN%%@${MENDER_TENANT_TOKEN}@g" /etc/mender/mender.conf

# Install Mender inventory file.
install -D -m 755 "${RECIPE_DIR}/files/mender-inventory-custom" -t /usr/share/mender/inventory
