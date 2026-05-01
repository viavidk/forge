#!/bin/bash
# Test: CLAUDE.md får ## Agent-orkestrering-sektion når Superpowers eller
# curated agents er aktive. Ikke når begge er fravalgt.
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

# Helper
gen_claude_md() {
  local proj="$1" sp="$2" ag="$3"
  rm -rf "$TMP/$proj"
  mkdir -p "$TMP/$proj"
  cp "$FORGE_ROOT/templates/partials/CLAUDE.md.base" "$TMP/$proj/CLAUDE.md"
  (
    set +u
    cd "$TMP"
    export PROJECT="$proj"
    export FORGE_ROOT
    export INSTALL_SUPERPOWERS="$sp"
    export INSTALL_AGENTS="$ag"
    source "$FORGE_ROOT/lib/_common.sh"
    source "$FORGE_ROOT/lib/09-claude-md.sh"
    generate_orchestration_section
  )
}

# Case 1: Fuld pakke — sektionen skal være der med alle 3 systemer beskrevet
gen_claude_md "fuld" "Y" "recommended"
fuld="$TMP/fuld/CLAUDE.md"
grep -q "## Agent-orkestrering" "$fuld"             || { echo "FAIL: Fuld mangler header"; exit 1; }
grep -q "Workflow-disciplin" "$fuld"                || { echo "FAIL: Fuld mangler Workflow-sektion"; exit 1; }
grep -q "Domain-ekspertise" "$fuld"                 || { echo "FAIL: Fuld mangler Domain-sektion"; exit 1; }
grep -q "Stack-specifik validering" "$fuld"         || { echo "FAIL: Fuld mangler Stack-sektion"; exit 1; }
grep -q "Hvornår bruger jeg hvad" "$fuld"           || { echo "FAIL: Fuld mangler decision-tabel"; exit 1; }
grep -q "forge agents cleanup" "$fuld"              || { echo "FAIL: Fuld mangler cleanup-reference"; exit 1; }

# Case 2: Ingen ekstras — sektionen må IKKE være der
gen_claude_md "ingen" "N" "none"
ingen="$TMP/ingen/CLAUDE.md"
grep -q "## Agent-orkestrering" "$ingen"            && { echo "FAIL: Ingen viser orkestrerings-sektion"; exit 1; }

# Case 3: Kun Superpowers — sektionen skal være der
gen_claude_md "kun-sp" "Y" "none"
grep -q "## Agent-orkestrering" "$TMP/kun-sp/CLAUDE.md" || { echo "FAIL: Kun-SP mangler orkestrering"; exit 1; }

# Case 4: Kun agents — sektionen skal være der
gen_claude_md "kun-ag" "N" "recommended"
grep -q "## Agent-orkestrering" "$TMP/kun-ag/CLAUDE.md" || { echo "FAIL: Kun-AG mangler orkestrering"; exit 1; }

echo "PASS: orchestration-claude-md — sektion render conditional + indeholder alle 3 systemer"
