#!/bin/bash
# Test: forge agents cleanup --apply sletter Forge's gamle dublerede agents
# efter brugerbekræftelse, og bevarer ikke-Forge-agents.
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

cd "$TMP"
mkdir -p .claude/agents

# Simulér v3.6.2-projekt
git -C "$FORGE_ROOT" show v3.6.2:templates/agents/code-reviewer.md > .claude/agents/code-reviewer.md
git -C "$FORGE_ROOT" show v3.6.2:templates/agents/security-auditor.md > .claude/agents/security-auditor.md
git -C "$FORGE_ROOT" show v3.6.2:templates/agents/performance-reviewer.md > .claude/agents/performance-reviewer.md
# Bevares: stack-agent og generisk
echo "# generic" > .claude/agents/some-other-agent.md
git -C "$FORGE_ROOT" show v3.6.2:templates/agents/frontend-reviewer.md > .claude/agents/frontend-reviewer.md

# Case 1: --apply med "y" → sletter
out=$(echo "y" | bash "$FORGE_ROOT/start-forge.sh" agents cleanup --apply 2>&1)
echo "$out" | grep -q "Slettet code-reviewer"          || { echo "FAIL: --apply slettede ikke code-reviewer"; exit 1; }
echo "$out" | grep -q "Slettet security-auditor"       || { echo "FAIL: --apply slettede ikke security-auditor"; exit 1; }
echo "$out" | grep -q "Slettet performance-reviewer"   || { echo "FAIL: --apply slettede ikke performance-reviewer"; exit 1; }
echo "$out" | grep -q "Cleanup færdig"                 || { echo "FAIL: --apply mangler success-message"; exit 1; }

# Filerne SKAL være væk
[ ! -f .claude/agents/code-reviewer.md ]               || { echo "FAIL: code-reviewer.md ikke slettet"; exit 1; }
[ ! -f .claude/agents/security-auditor.md ]            || { echo "FAIL: security-auditor.md ikke slettet"; exit 1; }
[ ! -f .claude/agents/performance-reviewer.md ]        || { echo "FAIL: performance-reviewer.md ikke slettet"; exit 1; }

# Andre agents bevares
[ -f .claude/agents/some-other-agent.md ]              || { echo "FAIL: ikke-Forge agent fjernet"; exit 1; }
[ -f .claude/agents/frontend-reviewer.md ]             || { echo "FAIL: stack-agent fjernet"; exit 1; }

# Case 2: --apply med "N" (default) → afbryd, ingen sletning
mkdir -p case2/.claude/agents && cd case2
git -C "$FORGE_ROOT" show v3.6.2:templates/agents/code-reviewer.md > .claude/agents/code-reviewer.md
out=$(echo "" | bash "$FORGE_ROOT/start-forge.sh" agents cleanup --apply 2>&1)
echo "$out" | grep -qi "annulleret\|ikke slettet"      || { echo "FAIL: 'N' annullerede ikke"; exit 1; }
[ -f .claude/agents/code-reviewer.md ]                 || { echo "FAIL: 'N' slettede alligevel"; exit 1; }

echo "PASS: forge-agents-cleanup-apply — sletter ved 'y', afbryder ved 'N'"
