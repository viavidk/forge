#!/bin/bash
# Test: når Superpowers fravælges må intet plugins.json oprettes
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

cd "$TMP"
export FORGE_ROOT
export PROJECT="testprojekt"
export INSTALL_SUPERPOWERS="N"

for lib in "$FORGE_ROOT/lib/"*.sh; do source "$lib"; done

mkdir -p "$PROJECT"
install_superpowers >/dev/null 2>&1

if [ -f "$PROJECT/.claude/plugins.json" ]; then
  echo "FAIL: plugins.json oprettet selvom INSTALL_SUPERPOWERS=N"
  exit 1
fi
if [ -f "$PROJECT/.claude-plugin/marketplace.json" ]; then
  echo "FAIL: marketplace.json oprettet selvom INSTALL_SUPERPOWERS=N"
  exit 1
fi

echo "PASS: superpowers-skip — ingen filer ved fravalg"
