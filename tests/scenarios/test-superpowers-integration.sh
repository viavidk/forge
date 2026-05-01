#!/bin/bash
# Test: Superpowers konfiguration genereres korrekt når valgt
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

cd "$TMP"
export FORGE_ROOT
export PROJECT="testprojekt"
export INSTALL_SUPERPOWERS="Y"

for lib in "$FORGE_ROOT/lib/"*.sh; do source "$lib"; done

mkdir -p "$PROJECT"
install_superpowers >/dev/null 2>&1

[ -f "$PROJECT/.claude/plugins.json" ]                  || { echo "FAIL: plugins.json mangler"; exit 1; }
[ -f "$PROJECT/.claude-plugin/marketplace.json" ]       || { echo "FAIL: marketplace.json mangler"; exit 1; }
grep -q "superpowers"           "$PROJECT/.claude/plugins.json"            || { echo "FAIL: plugins.json indeholder ikke 'superpowers'"; exit 1; }
grep -q "obra/superpowers-marketplace" "$PROJECT/.claude-plugin/marketplace.json" || { echo "FAIL: marketplace ikke obra/superpowers-marketplace"; exit 1; }

echo "PASS: superpowers-integration — plugins.json + marketplace.json korrekt"
