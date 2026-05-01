#!/bin/bash
# Test: INSTALL_AGENTS=none → ingen curated agents installeres
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

cd "$TMP"
export FORGE_ROOT
export PROJECT="testprojekt"
export PROJECT_TYPE="dashboard"
export INSTALL_AGENTS="none"

for lib in "$FORGE_ROOT/lib/"*.sh; do source "$lib"; done

mkdir -p "$PROJECT/.claude/agents"
install_recommended_agents >/dev/null 2>&1

# Ingen curated agents må være installeret
for agent in php-pro sql-pro security-auditor performance-engineer; do
  if [ -f "$PROJECT/.claude/agents/${agent}.md" ]; then
    echo "FAIL: $agent.md installeret selvom INSTALL_AGENTS=none"
    exit 1
  fi
done

echo "PASS: agents-skip — ingen curated agents installeret"
