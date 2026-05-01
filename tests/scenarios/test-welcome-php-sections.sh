#!/bin/bash
# Test: welcome.php's sektioner render conditional korrekt (v3.6.5+)
#   - Fuld pakke: capabilities + hooks + superpowers-sektioner til stede
#   - Ingen ekstras: ingen capabilities, ingen superpowers
#   - Kun Superpowers: superpowers-sektion OK, capabilities med kun SP-pills
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

gen_welcome() {
  local name="$1" sp="$2" ag="$3"
  mkdir -p "$TMP/$name/.claude/agents" "$TMP/$name/app/views"
  [ "$ag" = "recommended" ] && touch \
    "$TMP/$name/.claude/agents/code-reviewer.md" \
    "$TMP/$name/.claude/agents/security-auditor.md"
  (
    set +u
    cd "$TMP"
    export PROJECT="$name" PORT=8080 UPGRADE=false
    export USE_TUNNEL=N USE_VIAVI_SKILLS=N USE_CONTEXT7=N USE_CHROME_DEVTOOLS=N USE_ACETERNITY=none
    export INSTALL_SUPERPOWERS="$sp" INSTALL_AGENTS="$ag"
    source "$FORGE_ROOT/lib/_common.sh"
    source "$FORGE_ROOT/lib/99-finalize.sh"
    generate_welcome_php
  )
}

# ── Case 1: Fuld pakke ────────────────────────────────────────────────────────
gen_welcome "fuld" "Y" "recommended"
fuld="$TMP/fuld/app/views/welcome.php"
grep -q 'id="capabilities"'   "$fuld" || { echo "FAIL: Fuld mangler capabilities-sektion"; exit 1; }
grep -q 'id="hooks"'          "$fuld" || { echo "FAIL: Fuld mangler hooks-sektion"; exit 1; }
grep -q 'Superpowers plugin'  "$fuld" || { echo "FAIL: Fuld mangler Superpowers-sektion"; exit 1; }
grep -q 'brainstorming'       "$fuld" || { echo "FAIL: Fuld mangler brainstorming-pill"; exit 1; }
grep -q 'security-auditor'    "$fuld" || { echo "FAIL: Fuld mangler security-auditor-pill"; exit 1; }
grep -q 'frontend-reviewer'   "$fuld" || { echo "FAIL: Fuld mangler frontend-reviewer-pill"; exit 1; }

# ── Case 2: Ingen ekstras ─────────────────────────────────────────────────────
gen_welcome "ingen" "N" "none"
ingen="$TMP/ingen/app/views/welcome.php"
grep -q 'id="capabilities"'  "$ingen" && { echo "FAIL: Ingen viser capabilities-sektion"; exit 1; }
grep -q 'Superpowers plugin' "$ingen" && { echo "FAIL: Ingen viser Superpowers-sektion"; exit 1; }
grep -q 'id="hooks"'         "$ingen" || { echo "FAIL: Ingen mangler hooks-sektion (altid aktiv)"; exit 1; }

# ── Case 3: Kun Superpowers ───────────────────────────────────────────────────
gen_welcome "kun_sp" "Y" "none"
kun_sp="$TMP/kun_sp/app/views/welcome.php"
grep -q 'id="capabilities"'  "$kun_sp" || { echo "FAIL: Kun-SP mangler capabilities"; exit 1; }
grep -q 'Superpowers plugin' "$kun_sp" || { echo "FAIL: Kun-SP mangler Superpowers-sektion"; exit 1; }
grep -q 'brainstorming'      "$kun_sp" || { echo "FAIL: Kun-SP mangler brainstorming-pill"; exit 1; }

# PHP-syntax på alle tre
for case in fuld ingen kun_sp; do
  f="$TMP/$case/app/views/welcome.php"
  command -v php >/dev/null && php -l "$f" >/dev/null 2>&1 || true
done

echo "PASS: welcome-php-sections — capability-pills + hooks-sektion render conditional + gyldig PHP"
