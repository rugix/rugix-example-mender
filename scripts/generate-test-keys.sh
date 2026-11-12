#!/usr/bin/env bash

set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

rm -rf keys
mkdir keys
ssh-keygen -t rsa -b 4096 -f keys/id_rsa -q -N ""
