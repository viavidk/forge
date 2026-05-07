#!/bin/bash
set -e
FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# T1: VERSION file exists and is semver
ver=$(cat "$FORGE_ROOT/VERSION" 2>/dev/null || echo "")
echo "$ver" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$' || { echo "FAIL T1: VERSION file missing or not semver (got: '$ver')"; exit 1; }

# T1: get_local_version() reads it
source "$FORGE_ROOT/lib/_common.sh"
got=$(get_local_version)
[ "$got" = "$ver" ] || { echo "FAIL T1: get_local_version() returned '$got', expected '$ver'"; exit 1; }

echo "PASS T1: VERSION file + get_local_version()"
