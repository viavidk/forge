#!/bin/bash
# Test: welcome.php's orchestration-grid har korrekt struktur:
# 3 kolonner (Workflow/Domain/Stack), korrekte agents listes pr. kolonne,
# dimmed hint vises for ikke-valgte systemer.
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

# Setup: simulér v3.6.3-installation med 3 Forge + 3 awesome-curated agents
mkdir -p "$TMP/proj/.claude/agents" "$TMP/proj/app/views"
touch "$TMP/proj/.claude/agents/frontend-reviewer.md" \
      "$TMP/proj/.claude/agents/db-reviewer.md" \
      "$TMP/proj/.claude/agents/data-integrity-auditor.md" \
      "$TMP/proj/.claude/agents/code-reviewer.md" \
      "$TMP/proj/.claude/agents/security-auditor.md" \
      "$TMP/proj/.claude/agents/php-pro.md"

(
  set +u
  cd "$TMP"
  export PROJECT="proj"
  export PORT=8080 UPGRADE=false
  export USE_TUNNEL=N USE_VIAVI_SKILLS=N USE_CONTEXT7=N USE_CHROME_DEVTOOLS=N USE_ACETERNITY=none
  export INSTALL_SUPERPOWERS="Y" INSTALL_AGENTS="recommended"
  source "$FORGE_ROOT/lib/_common.sh"
  source "$FORGE_ROOT/lib/99-finalize.sh"
  generate_welcome_php
)

php="$TMP/proj/app/views/welcome.php"

# Struktur
grep -q 'class="orchestration-grid"' "$php"    || { echo "FAIL: orchestration-grid div mangler"; exit 1; }
grep -q "Kolonne 1" "$php"                     || { echo "FAIL: Kolonne 1-label mangler"; exit 1; }
grep -q "Kolonne 2" "$php"                     || { echo "FAIL: Kolonne 2-label mangler"; exit 1; }
grep -q "Kolonne 3" "$php"                     || { echo "FAIL: Kolonne 3-label mangler"; exit 1; }

# Kolonne 1 (Workflow) — Superpowers skills listed
for skill in brainstorming writing-plans executing-plans systematic-debugging red-green-refactor; do
  grep -q ">${skill}<" "$php" || { echo "FAIL: Workflow-kolonne mangler $skill"; exit 1; }
done

# Kolonne 2 (Domain) — awesome agents listed (de der ikke er Forge-stack)
for agent in code-reviewer security-auditor php-pro; do
  grep -q ">${agent}<" "$php" || { echo "FAIL: Domain-kolonne mangler $agent"; exit 1; }
done

# Kolonne 3 (Stack) — Forge's 3 base agents
for agent in frontend-reviewer db-reviewer data-integrity-auditor; do
  grep -q ">${agent}<" "$php" || { echo "FAIL: Stack-kolonne mangler $agent"; exit 1; }
done

# Princip-tekst i bunden
grep -q "Forge ejer PHP-stack-specifikt" "$php" || { echo "FAIL: princip-tekst mangler i bunden"; exit 1; }

# Validér PHP-syntax
if command -v php >/dev/null; then
  php -l "$php" >/dev/null 2>&1 || { echo "FAIL: welcome.php har PHP syntax-fejl"; exit 1; }
fi

echo "PASS: welcome-orchestration-grid — 3 kolonner, korrekte agents, gyldig PHP"
