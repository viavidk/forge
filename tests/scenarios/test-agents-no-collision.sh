#!/bin/bash
# Test: Forge's egne agents (code-reviewer fra templates/agents/) overskrives
# IKKE af awesome-versionen — Forge-versionen vinder.
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

# Læg en sentinel som "Forge's egen code-reviewer"
echo "FORGE-MARKER" > "$PROJECT/.claude/agents/code-reviewer.md"

install_recommended_agents >/dev/null 2>&1 || true

# Sentinel skal stadig være der — awesome-versionen må ikke overskrive
if ! grep -q "FORGE-MARKER" "$PROJECT/.claude/agents/code-reviewer.md"; then
  echo "FAIL: awesome code-reviewer overskrev Forge's version"
  exit 1
fi

echo "PASS: agents-no-collision — Forge's egne agents bevares"
