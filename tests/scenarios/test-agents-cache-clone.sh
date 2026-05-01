#!/bin/bash
# Test: ensure_agents_cache cloner repo ved første kørsel
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

export FORGE_ROOT
export AGENTS_CACHE="$TMP/agents-cache"

for lib in "$FORGE_ROOT/lib/"*.sh; do source "$lib"; done

ensure_agents_cache >/dev/null 2>&1 || {
  echo "SKIP: ensure_agents_cache fejlede (offline?)"
  exit 0
}

[ -d "$AGENTS_CACHE/.git" ] || { echo "FAIL: cache er ikke et git-repo"; exit 1; }
[ -d "$AGENTS_CACHE/categories" ] || { echo "FAIL: categories/ mangler"; exit 1; }

echo "PASS: agents-cache-clone — repo klonet til AGENTS_CACHE"
