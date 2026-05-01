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

if [ -f "$PROJECT/.claude/settings.json" ]; then
  # Filen MÅ eksistere men må ikke have superpowers i sig
  python3 -c "
import json
d = json.load(open('$PROJECT/.claude/settings.json'))
assert 'superpowers' not in d.get('enabledPlugins', []), 'superpowers tilføjet selvom fravalgt'
" || { echo "FAIL: settings.json indeholder superpowers selvom fravalgt"; exit 1; }
fi

echo "PASS: superpowers-skip — superpowers IKKE i enabledPlugins ved fravalg"
