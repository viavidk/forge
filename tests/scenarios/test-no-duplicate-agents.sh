#!/bin/bash
# Test: Efter scaffold må der ikke være DUBLEREDE agents (samme navn flere gange)
# Plus: Forge's slettede agents (code-reviewer, security-auditor, performance-reviewer)
# må IKKE komme fra templates/agents/ — kun fra awesome-cache.
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

cd "$TMP"
export FORGE_ROOT
export PROJECT="testprojekt"
export PROJECT_TYPE="dashboard"
export INSTALL_AGENTS="recommended"
export USE_CHROME_DEVTOOLS="N"
export USE_VIAVI_SKILLS="N"
export USE_CONTEXT7="N"
export PORT=8080

for lib in "$FORGE_ROOT/lib/"*.sh; do source "$lib"; done

mkdir -p "$PROJECT"
install_agents >/dev/null 2>&1
install_recommended_agents >/dev/null 2>&1 || true

# Tjek 1: Ingen .md-fil må eksistere mere end én gang (basename-niveau)
duplicates=$(ls "$PROJECT/.claude/agents/" | sort | uniq -d)
if [ -n "$duplicates" ]; then
  echo "FAIL: dubletter fundet: $duplicates"
  exit 1
fi

# Tjek 2: De 3 dropped Forge-templates findes ikke i templates/agents/
for dropped in code-reviewer security-auditor performance-reviewer; do
  if [ -f "$FORGE_ROOT/templates/agents/${dropped}.md" ]; then
    echo "FAIL: $dropped.md findes stadig i templates/agents/ (skulle være slettet i v3.6.3)"
    exit 1
  fi
done

# Tjek 3: De installerede code-reviewer/security-auditor er awesome-versioner
# (ikke Forge's PHP-specifikke). Awesome-versioner mangler PHP-stack-specifikke
# referencer i frontmatter description.
for name in code-reviewer security-auditor; do
  f="$PROJECT/.claude/agents/${name}.md"
  [ -f "$f" ] || continue
  if grep -qE "Strict PHP|PHP code (quality )?reviewer|vulnerabilities in PHP" "$f"; then
    echo "FAIL: $name.md ser ud til stadig at være Forge-version (har PHP-stack referencer)"
    exit 1
  fi
done

echo "PASS: no-duplicate-agents — ingen dubletter, ingen Forge-versioner af dropped agents"
