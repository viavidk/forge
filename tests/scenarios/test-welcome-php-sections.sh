#!/bin/bash
# Test: welcome.php inkluderer Superpowers- og awesome-agents-sektioner KUN når valgt
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

# Helper: generér welcome.php med givne env-vars
gen_welcome() {
  local proj="$1" sp="$2" ag="$3"
  mkdir -p "$TMP/$proj/.claude/agents" "$TMP/$proj/app/views"
  touch "$TMP/$proj/.claude/agents/php-pro.md" "$TMP/$proj/.claude/agents/api-designer.md" "$TMP/$proj/.claude/agents/code-reviewer.md"
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

# Case 1: Fuld pakke — begge sektioner skal være med
gen_welcome "fuld" "Y" "recommended"
fuld="$TMP/fuld/app/views/welcome.php"
grep -q "Superpowers plugin" "$fuld"     || { echo "FAIL: Fuld mangler Superpowers-sektion"; exit 1; }
grep -q "Curated awesome-agents" "$fuld" || { echo "FAIL: Fuld mangler awesome-agents-sektion"; exit 1; }
grep -q "Clarify" "$fuld"                || { echo "FAIL: Fuld mangler Clarify-trin"; exit 1; }
grep -q "api-designer" "$fuld"           || { echo "FAIL: Fuld viser ikke api-designer"; exit 1; }
grep -q "php-pro" "$fuld"                || { echo "FAIL: Fuld viser ikke php-pro"; exit 1; }
# Forge's egne agents må IKKE listes i awesome-sektionen (kun curated)
grep -A2 "Curated awesome-agents" "$fuld" | grep -q "code-reviewer" \
  && { echo "FAIL: Forge's code-reviewer fejlagtigt vist som awesome-agent"; exit 1; }

# Case 2: Ingen ekstras — sektionerne må IKKE være med
gen_welcome "ingen" "N" "none"
ingen="$TMP/ingen/app/views/welcome.php"
grep -q "Superpowers plugin" "$ingen"     && { echo "FAIL: Ingen viser Superpowers-sektion"; exit 1; }
grep -q "Curated awesome-agents" "$ingen" && { echo "FAIL: Ingen viser awesome-agents-sektion"; exit 1; }

# Case 3: Kun Superpowers
gen_welcome "kun-sp" "Y" "none"
kun_sp="$TMP/kun-sp/app/views/welcome.php"
grep -q "Superpowers plugin" "$kun_sp"     || { echo "FAIL: Kun-SP mangler Superpowers"; exit 1; }
grep -q "Curated awesome-agents" "$kun_sp" && { echo "FAIL: Kun-SP viser awesome-agents-sektion"; exit 1; }

# Case 4: Kun curated agents
gen_welcome "kun-ag" "N" "recommended"
kun_ag="$TMP/kun-ag/app/views/welcome.php"
grep -q "Superpowers plugin" "$kun_ag"     && { echo "FAIL: Kun-AG viser Superpowers-sektion"; exit 1; }
grep -q "Curated awesome-agents" "$kun_ag" || { echo "FAIL: Kun-AG mangler awesome-agents-sektion"; exit 1; }

# Version vises i nav og footer
grep -q "ViaVi Forge v3.6.2" "$fuld" || { echo "FAIL: nav viser ikke v3.6.2"; exit 1; }

# forge agents CLI-row skal være med uanset valg (informativ)
grep -q "forge agents" "$ingen" || { echo "FAIL: forge agents CLI-row mangler i Ingen"; exit 1; }

echo "PASS: welcome-php-sections — alle 4 disciplin-valg har korrekt conditional content"
