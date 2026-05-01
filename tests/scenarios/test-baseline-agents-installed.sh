#!/bin/bash
# Test: Baseline (code-reviewer/security-auditor/performance-engineer fra awesome)
# installeres ALTID ved INSTALL_AGENTS=recommended uanset projekttype
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

for ptype in dashboard internal website ecommerce api; do
  TMP=$(mktemp -d)
  cd "$TMP"
  export FORGE_ROOT
  export PROJECT="proj-$ptype"
  export PROJECT_TYPE="$ptype"
  export INSTALL_AGENTS="recommended"

  for lib in "$FORGE_ROOT/lib/"*.sh; do source "$lib"; done

  mkdir -p "$PROJECT/.claude/agents"
  install_recommended_agents >/dev/null 2>&1 || true

  for required in code-reviewer security-auditor performance-engineer; do
    if [ ! -f "$PROJECT/.claude/agents/${required}.md" ]; then
      echo "FAIL: $ptype mangler baseline-agent $required"
      rm -rf "$TMP"
      exit 1
    fi
  done

  rm -rf "$TMP"
done

echo "PASS: baseline-agents-installed — code-reviewer/security-auditor/performance-engineer for alle 5 typer"
