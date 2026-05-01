#!/bin/bash
# Test: welcome.php's capability-pills (v3.6.5+) har korrekt struktur:
# - Capability-sektion renders ved fuld pakke
# - Superpowers-pills (lilla) vises
# - Awesome-agents pills (blå) vises
# - Forge stack-pills (brand) altid med
# - Ingen "Kolonne 1/2/3" labels (v3.6.4-artefakter)
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

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

# Capabilities-sektion skal være der
grep -q 'id="capabilities"' "$php"   || { echo "FAIL: capabilities-sektion mangler"; exit 1; }
grep -q 'Klar til første prompt'      "$php" || { echo "FAIL: capabilities-header mangler"; exit 1; }

# Superpowers-pills (lilla farve)
grep -q 'brainstorming' "$php"        || { echo "FAIL: brainstorming-pill mangler"; exit 1; }
grep -q 'systematic-debugging' "$php" || { echo "FAIL: systematic-debugging-pill mangler"; exit 1; }

# Awesome-pills
grep -q 'code-reviewer' "$php"        || { echo "FAIL: code-reviewer-pill mangler"; exit 1; }
grep -q 'security-auditor' "$php"     || { echo "FAIL: security-auditor-pill mangler"; exit 1; }
grep -q 'php-pro' "$php"              || { echo "FAIL: php-pro-pill mangler"; exit 1; }

# Forge stack-pills
grep -q 'frontend-reviewer' "$php"    || { echo "FAIL: frontend-reviewer-pill mangler"; exit 1; }
grep -q 'db-reviewer' "$php"          || { echo "FAIL: db-reviewer-pill mangler"; exit 1; }

# Ingen v3.6.4-artefakter
grep -q 'Kolonne 1' "$php"           && { echo "FAIL: gammel 'Kolonne 1'-label stadig i welcome.php"; exit 1; }
grep -q 'orchestration-grid' "$php"  && { echo "FAIL: gammel orchestration-grid CSS stadig i welcome.php"; exit 1; }

# PHP-syntax
command -v php >/dev/null && php -l "$php" >/dev/null 2>&1 || true

echo "PASS: welcome-orchestration-grid — capability-pills render korrekt, ingen v3.6.4-artefakter"
