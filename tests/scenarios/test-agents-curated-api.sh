#!/bin/bash
# Test: api-projekttype får api-designer + sikkerhed/kvalitet curated agents
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

cd "$TMP"
export FORGE_ROOT
export PROJECT="testprojekt"
export PROJECT_TYPE="api"
export INSTALL_AGENTS="recommended"

for lib in "$FORGE_ROOT/lib/"*.sh; do source "$lib"; done

mkdir -p "$PROJECT"
install_recommended_agents >/dev/null 2>&1 || true

[ -f "$PROJECT/.claude/agents/api-designer.md" ]   || { echo "FAIL: api-designer.md mangler for api"; exit 1; }
[ -f "$PROJECT/.claude/agents/security-auditor.md" ] || { echo "FAIL: security-auditor.md mangler"; exit 1; }
[ -f "$PROJECT/.claude/agents/code-reviewer.md" ]  || { echo "FAIL: code-reviewer.md mangler"; exit 1; }

echo "PASS: agents-curated-api — api-designer + security-auditor + code-reviewer installeret"
