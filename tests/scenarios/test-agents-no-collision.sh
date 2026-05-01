#!/bin/bash
# Test: install_recommended_agents bruger cp -n — eksisterende agent-filer
# overskrives ikke. v3.6.3: Forge ejer kun stack-specifikke agents, så vi
# tester med frontend-reviewer (som stadig er en Forge-template).
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

cd "$TMP"
export FORGE_ROOT
export PROJECT="testprojekt"
export PROJECT_TYPE="dashboard"
export INSTALL_AGENTS="recommended"

for lib in "$FORGE_ROOT/lib/"*.sh; do source "$lib"; done

mkdir -p "$PROJECT/.claude/agents"

# Sentinel: hvis brugeren har en custom code-reviewer.md (fx fra awesome-cache),
# må install_recommended_agents IKKE overskrive den.
echo "USER-CUSTOM-MARKER" > "$PROJECT/.claude/agents/code-reviewer.md"

install_recommended_agents >/dev/null 2>&1 || true

# Sentinel skal stadig være der — cp -n stopper overwrite
if ! grep -q "USER-CUSTOM-MARKER" "$PROJECT/.claude/agents/code-reviewer.md"; then
  echo "FAIL: install_recommended_agents overskrev eksisterende code-reviewer.md"
  exit 1
fi

echo "PASS: agents-no-collision — cp -n bevarer eksisterende agent-filer"
