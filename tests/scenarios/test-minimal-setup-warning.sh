#!/bin/bash
# Test: warn_minimal_setup advarer når Superpowers=N og agents=none, og
# kalder prompt_agentic_discipline igen ved "N" (default).
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

for lib in "$FORGE_ROOT/lib/"*.sh; do source "$lib"; done

# Vi kan ikke bruge $()-capture pga. subshell — INSTALL_*-vars assigned i
# subshell ville være tabt. I stedet skriver vi advarsels-output til fil og
# tjekker INSTALL_*-vars direkte i parent shell efter funktions-kald.

OUTFILE=$(mktemp)
trap "rm -f $OUTFILE" EXIT

PROJECT_TYPE="dashboard"
PROJECT_PROFILE="intern"
FORGE_MODE="guided"

# Case 1: Minimal setup + svar "N" → prompten kører igen, "1" → fuld pakke
INSTALL_SUPERPOWERS="N"
INSTALL_AGENTS="none"
warn_minimal_setup <<<"$(printf 'N\n1\n')" >"$OUTFILE" 2>&1

grep -qE "ingen Superpowers og ingen curated|minimal setup" "$OUTFILE" \
  || { echo "FAIL: warn_minimal_setup viste ikke advarsel"; cat "$OUTFILE"; exit 1; }

[ "$INSTALL_SUPERPOWERS" = "Y" ]      || { echo "FAIL: rekursiv prompt satte ikke INSTALL_SUPERPOWERS=Y (fik: $INSTALL_SUPERPOWERS)"; exit 1; }
[ "$INSTALL_AGENTS" = "recommended" ] || { echo "FAIL: rekursiv prompt satte ikke INSTALL_AGENTS=recommended (fik: $INSTALL_AGENTS)"; exit 1; }

# Case 2: Bekræfter med "y" → ingen rekursion, valgene bevares
INSTALL_SUPERPOWERS="N"
INSTALL_AGENTS="none"
warn_minimal_setup <<<"y" >"$OUTFILE" 2>&1
[ "$INSTALL_SUPERPOWERS" = "N" ] || { echo "FAIL: 'y' bevarede ikke INSTALL_SUPERPOWERS=N"; exit 1; }
[ "$INSTALL_AGENTS" = "none" ]   || { echo "FAIL: 'y' bevarede ikke INSTALL_AGENTS=none"; exit 1; }

# Case 3: Ikke-minimal setup → ingen advarsel, ingen prompt
INSTALL_SUPERPOWERS="Y"
INSTALL_AGENTS="recommended"
warn_minimal_setup </dev/null >"$OUTFILE" 2>&1
grep -qi "minimal\|ingen Superpowers" "$OUTFILE" \
  && { echo "FAIL: warn_minimal_setup advarede selvom ikke minimal"; exit 1; } || true

echo "PASS: minimal-setup-warning — advarsel + bekræftelse + restart-flow virker"
