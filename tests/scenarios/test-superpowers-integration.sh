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

[ -f "$PROJECT/.claude/settings.json" ] || { echo "FAIL: .claude/settings.json mangler"; exit 1; }

python3 -c "
import json, sys
d = json.load(open('$PROJECT/.claude/settings.json'))
assert 'superpowers' in d.get('enabledPlugins', []), 'superpowers ikke i enabledPlugins'
mps = d.get('extraKnownMarketplaces', [])
assert any(m.get('url','').endswith('obra/superpowers-marketplace') for m in mps), 'obra/superpowers-marketplace ikke i extraKnownMarketplaces'
" || { echo "FAIL: settings.json struktur forkert"; exit 1; }

echo "PASS: superpowers-integration — .claude/settings.json med enabledPlugins + extraKnownMarketplaces"
