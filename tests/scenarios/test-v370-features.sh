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

# T2: check_for_update writes .update-checked file
rm -f "$FORGE_ROOT/.update-checked"
check_for_update_test() {
  local check_file="${FORGE_ROOT}/.update-checked"
  local today; today=$(date +%Y-%m-%d)
  [ -f "$check_file" ] && [ "$(cat "$check_file")" = "$today" ] && return 0
  echo "$today" > "$check_file"
  FORGE_UPDATE_AVAILABLE="99.0.0"
  export FORGE_UPDATE_AVAILABLE
}
check_for_update_test
[ -f "$FORGE_ROOT/.update-checked" ] || { echo "FAIL T2: .update-checked not written"; exit 1; }
[ "${FORGE_UPDATE_AVAILABLE:-}" = "99.0.0" ] || { echo "FAIL T2: FORGE_UPDATE_AVAILABLE not set"; exit 1; }
echo "PASS T2: check_for_update writes marker + sets FORGE_UPDATE_AVAILABLE"
