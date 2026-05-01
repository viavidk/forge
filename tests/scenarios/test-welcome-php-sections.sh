#!/bin/bash
# Test: welcome.php's orchestration-grid render conditional på Superpowers/agents-valg
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

# Helper: generér welcome.php med givne env-vars
gen_welcome() {
  local proj="$1" sp="$2" ag="$3"
  mkdir -p "$TMP/$proj/.claude/agents" "$TMP/$proj/app/views"
  # Simulér v3.6.3-installation: 3 base Forge + 3 awesome curated
  touch "$TMP/$proj/.claude/agents/frontend-reviewer.md" \
        "$TMP/$proj/.claude/agents/db-reviewer.md" \
        "$TMP/$proj/.claude/agents/data-integrity-auditor.md" \
        "$TMP/$proj/.claude/agents/php-pro.md" \
        "$TMP/$proj/.claude/agents/api-designer.md" \
        "$TMP/$proj/.claude/agents/code-reviewer.md"
  (
    set +u
    cd "$TMP"
    export PROJECT="$proj"
    export PORT=8080 UPGRADE=false
    export USE_TUNNEL=N USE_VIAVI_SKILLS=N USE_CONTEXT7=N USE_CHROME_DEVTOOLS=N USE_ACETERNITY=none
    export INSTALL_SUPERPOWERS="$sp" INSTALL_AGENTS="$ag"
    source "$FORGE_ROOT/lib/_common.sh"
    source "$FORGE_ROOT/lib/99-finalize.sh"
    generate_welcome_php
  )
}

# Case 1: Fuld pakke — orchestration-grid med alle 3 kolonner
gen_welcome "fuld" "Y" "recommended"
fuld="$TMP/fuld/app/views/welcome.php"
grep -q "Agent-orkestrering" "$fuld"     || { echo "FAIL: Fuld mangler Agent-orkestrering header"; exit 1; }
grep -q "orchestration-grid" "$fuld"     || { echo "FAIL: Fuld mangler orchestration-grid CSS"; exit 1; }
grep -q "Workflow" "$fuld"               || { echo "FAIL: Fuld mangler Workflow-kolonne"; exit 1; }
grep -q "Domain" "$fuld"                 || { echo "FAIL: Fuld mangler Domain-kolonne"; exit 1; }
grep -q "Stack" "$fuld"                  || { echo "FAIL: Fuld mangler Stack-kolonne"; exit 1; }
grep -q "Superpowers plugin" "$fuld"     || { echo "FAIL: Fuld mangler Superpowers-sektion"; exit 1; }
grep -q "frontend-reviewer" "$fuld"      || { echo "FAIL: Fuld mangler frontend-reviewer i Stack"; exit 1; }
grep -q "code-reviewer" "$fuld"          || { echo "FAIL: Fuld mangler code-reviewer i Domain"; exit 1; }
grep -q "php-pro" "$fuld"                || { echo "FAIL: Fuld mangler php-pro i Domain"; exit 1; }

# Case 2: Ingen ekstras — orchestration-grid må IKKE render
gen_welcome "ingen" "N" "none"
ingen="$TMP/ingen/app/views/welcome.php"
grep -q "Agent-orkestrering" "$ingen"   && { echo "FAIL: Ingen viser orchestration-grid"; exit 1; }
grep -q "Superpowers plugin" "$ingen"   && { echo "FAIL: Ingen viser Superpowers-sektion"; exit 1; }

# Case 3: Kun Superpowers — Workflow-kolonne aktiv, Domain-kolonne dimmed
gen_welcome "kun-sp" "Y" "none"
kun_sp="$TMP/kun-sp/app/views/welcome.php"
grep -q "Agent-orkestrering" "$kun_sp"  || { echo "FAIL: Kun-SP mangler orkestrering"; exit 1; }
grep -q "Superpowers plugin" "$kun_sp"  || { echo "FAIL: Kun-SP mangler Superpowers-sektion"; exit 1; }
grep -q "Awesome (ikke valgt)" "$kun_sp" || { echo "FAIL: Kun-SP viser ikke 'Awesome (ikke valgt)'"; exit 1; }

# Case 4: Kun curated agents — Domain-kolonne aktiv, Workflow-kolonne dimmed
gen_welcome "kun-ag" "N" "recommended"
kun_ag="$TMP/kun-ag/app/views/welcome.php"
grep -q "Agent-orkestrering" "$kun_ag"   || { echo "FAIL: Kun-AG mangler orkestrering"; exit 1; }
grep -q "Superpowers plugin" "$kun_ag"   && { echo "FAIL: Kun-AG viser Superpowers-sektion"; exit 1; }
grep -q "Superpowers (ikke valgt)" "$kun_ag" || { echo "FAIL: Kun-AG viser ikke 'Superpowers (ikke valgt)'"; exit 1; }

# Version vises i nav og footer
grep -q "ViaVi Forge v3.6.3" "$fuld"     || { echo "FAIL: nav viser ikke v3.6.3"; exit 1; }

# forge agents CLI-row skal være med uanset valg (informativ)
grep -q "forge agents" "$ingen"          || { echo "FAIL: forge agents CLI-row mangler i Ingen"; exit 1; }

# v3.6.3: agent-section subtitle skal være "Stack-specifikke agents", ikke "Review-agenter"
grep -q "Stack-specifikke agents" "$fuld" || { echo "FAIL: agent-section title ikke opdateret til v3.6.3"; exit 1; }

echo "PASS: welcome-php-sections — orchestration-grid render conditional + v3.6.3 indhold"
