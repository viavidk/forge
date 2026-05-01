#!/bin/bash
# Test: FORGE_VERSION er bumped til 3.6.6
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

grep -q '^FORGE_VERSION="3.6.6"' "$FORGE_ROOT/start-forge.sh" \
  || { echo "FAIL: start-forge.sh har ikke FORGE_VERSION=3.6.6"; exit 1; }

grep -q 'v3.6.6' "$FORGE_ROOT/README.md" \
  || { echo "FAIL: README.md mangler v3.6.6 reference"; exit 1; }

# --help viser version
out=$(bash "$FORGE_ROOT/start-forge.sh" --help 2>&1)
echo "$out" | grep -q "v3.6.6" || { echo "FAIL: --help viser ikke v3.6.6"; exit 1; }

echo "PASS: version-bump — FORGE_VERSION=3.6.6 i start-forge.sh, README og --help"
