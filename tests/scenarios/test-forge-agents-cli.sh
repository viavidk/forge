#!/bin/bash
# Test: forge agents list/search/help virker
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# list
out=$(bash "$FORGE_ROOT/start-forge.sh" agents list 2>&1)
echo "$out" | grep -q "Tilgængelige kategorier" || { echo "FAIL: 'agents list' viser ikke kategorier"; exit 1; }
echo "$out" | grep -q "01-core-development"     || { echo "FAIL: 'agents list' mangler 01-core-development"; exit 1; }

# search
out=$(bash "$FORGE_ROOT/start-forge.sh" agents search code-reviewer 2>&1)
echo "$out" | grep -q "code-reviewer" || { echo "FAIL: 'agents search code-reviewer' fandt intet"; exit 1; }

# help (no subcommand)
out=$(bash "$FORGE_ROOT/start-forge.sh" agents 2>&1)
echo "$out" | grep -q "forge agents — håndter" || { echo "FAIL: 'agents' viser ikke help"; exit 1; }

echo "PASS: forge-agents-cli — list, search og help virker"
