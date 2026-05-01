#!/bin/bash
# Test: install_superpowers merger ind i eksisterende settings.json uden at slette andre felter
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

cd "$TMP"
export FORGE_ROOT
export PROJECT="testprojekt"
export INSTALL_SUPERPOWERS="Y"

for lib in "$FORGE_ROOT/lib/"*.sh; do source "$lib"; done

mkdir -p "$PROJECT/.claude"

# Eksisterende settings med andre felter + en marketplace
cat > "$PROJECT/.claude/settings.json" <<EOF
{
  "theme": "dark",
  "extraKnownMarketplaces": [
    { "url": "https://github.com/example/other-marketplace" }
  ],
  "enabledPlugins": ["other-plugin"]
}
EOF

install_superpowers >/dev/null 2>&1

python3 -c "
import json
d = json.load(open('$PROJECT/.claude/settings.json'))

# Andre felter skal være intakte
assert d.get('theme') == 'dark', 'theme felt mistet'

# Begge plugins skal være enabled
plugins = d.get('enabledPlugins', [])
assert 'other-plugin' in plugins, 'other-plugin fjernet ved merge'
assert 'superpowers' in plugins, 'superpowers ikke tilføjet'

# Begge marketplaces skal være med
mps = [m.get('url') for m in d.get('extraKnownMarketplaces', [])]
assert any('other-marketplace' in u for u in mps), 'eksisterende marketplace mistet'
assert any('obra/superpowers-marketplace' in u for u in mps), 'superpowers-marketplace ikke tilføjet'
" || { echo "FAIL: merge ødelagde eksisterende settings"; exit 1; }

# Idempotens: kør install_superpowers igen — må ikke duplikere
install_superpowers >/dev/null 2>&1
python3 -c "
import json
d = json.load(open('$PROJECT/.claude/settings.json'))
assert d['enabledPlugins'].count('superpowers') == 1, 'superpowers duplikeret'
mps_urls = [m.get('url') for m in d.get('extraKnownMarketplaces', [])]
sp_count = sum(1 for u in mps_urls if 'obra/superpowers-marketplace' in u)
assert sp_count == 1, f'superpowers-marketplace duplikeret ({sp_count}x)'
" || { echo "FAIL: idempotens brudt"; exit 1; }

echo "PASS: superpowers-merge — eksisterende settings bevaret + idempotent"
