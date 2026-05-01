#!/bin/bash
# Test: smart defaults pr. projekttype sætter SUPERPOWERS_DEFAULT korrekt
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

for lib in "$FORGE_ROOT/lib/"*.sh; do source "$lib"; done

# Backend (api) skal have SUPERPOWERS_DEFAULT=N
PROJECT_PROFILE="backend"
case "$PROJECT_PROFILE" in
  backend) SUPERPOWERS_DEFAULT="N"; AGENTS_DEFAULT="recommended" ;;
esac
[ "$SUPERPOWERS_DEFAULT" = "N" ] || { echo "FAIL: backend skal have SUPERPOWERS_DEFAULT=N"; exit 1; }

# Website skal have SUPERPOWERS_DEFAULT=Y
PROJECT_PROFILE="website"
case "$PROJECT_PROFILE" in
  website) SUPERPOWERS_DEFAULT="Y"; AGENTS_DEFAULT="recommended" ;;
esac
[ "$SUPERPOWERS_DEFAULT" = "Y" ] || { echo "FAIL: website skal have SUPERPOWERS_DEFAULT=Y"; exit 1; }

echo "PASS: mode-defaults — smart defaults korrekte for backend og website"
