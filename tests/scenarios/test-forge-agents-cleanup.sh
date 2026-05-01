#!/bin/bash
# Test: forge agents cleanup (dry-run) detekterer Forge's gamle dublerede
# agents fra v3.6.2 og foreslår sletning uden at slette.
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

cd "$TMP"
mkdir -p .claude/agents

# Simulér v3.6.2-projekt: hent Forge's gamle agent-templates fra git history
git -C "$FORGE_ROOT" show v3.6.2:templates/agents/code-reviewer.md > .claude/agents/code-reviewer.md
git -C "$FORGE_ROOT" show v3.6.2:templates/agents/security-auditor.md > .claude/agents/security-auditor.md
git -C "$FORGE_ROOT" show v3.6.2:templates/agents/performance-reviewer.md > .claude/agents/performance-reviewer.md
# Plus en agent der IKKE skal flagges
echo "# generic" > .claude/agents/some-other-agent.md

# Kør dry-run cleanup
out=$(bash "$FORGE_ROOT/start-forge.sh" agents cleanup 2>&1)

echo "$out" | grep -q "Detekterede dubletter"          || { echo "FAIL: cleanup viser ikke header"; exit 1; }
echo "$out" | grep -q "code-reviewer.md"               || { echo "FAIL: cleanup detekterer ikke code-reviewer"; exit 1; }
echo "$out" | grep -q "security-auditor.md"            || { echo "FAIL: cleanup detekterer ikke security-auditor"; exit 1; }
echo "$out" | grep -q "performance-reviewer.md"        || { echo "FAIL: cleanup detekterer ikke performance-reviewer"; exit 1; }
echo "$out" | grep -q "some-other-agent"               && { echo "FAIL: cleanup flaggede irrelevant agent"; exit 1; } || true
echo "$out" | grep -q "forge agents cleanup --apply"   || { echo "FAIL: cleanup mangler --apply hint"; exit 1; }

# Filerne skal stadig være der efter dry-run
[ -f .claude/agents/code-reviewer.md ]                 || { echo "FAIL: dry-run slettede code-reviewer"; exit 1; }
[ -f .claude/agents/security-auditor.md ]              || { echo "FAIL: dry-run slettede security-auditor"; exit 1; }
[ -f .claude/agents/performance-reviewer.md ]          || { echo "FAIL: dry-run slettede performance-reviewer"; exit 1; }

echo "PASS: forge-agents-cleanup — dry-run detekterer Forge-versioner uden at slette"
