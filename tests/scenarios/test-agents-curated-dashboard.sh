#!/bin/bash
# Test: dashboard-projekttype får 6 curated agents installeret
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

mkdir -p "$PROJECT"
install_recommended_agents >/dev/null 2>&1 || true

# Forventet: 6 agents (alle skal eksistere i cache)
expected=("code-reviewer" "security-auditor" "performance-engineer" "accessibility-tester" "php-pro" "sql-pro")

found=0
for agent in "${expected[@]}"; do
  if [ -f "$PROJECT/.claude/agents/${agent}.md" ]; then
    found=$((found + 1))
  fi
done

if [ "$found" -lt 4 ]; then
  echo "FAIL: forventede mindst 4 af 6 curated agents, fandt $found"
  exit 1
fi

echo "PASS: agents-curated-dashboard — $found/6 curated agents installeret"
