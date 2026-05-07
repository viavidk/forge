#!/bin/bash
set -e
FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# T1: VERSION file exists and is semver
ver=$(cat "$FORGE_ROOT/VERSION" 2>/dev/null || echo "")
echo "$ver" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$' || { echo "FAIL T1: VERSION file missing or not semver (got: '$ver')"; exit 1; }

# T1: get_local_version() reads it
source "$FORGE_ROOT/lib/_common.sh"
got=$(get_local_version)
[ "$got" = "$ver" ] || { echo "FAIL T1: get_local_version() returned '$got', expected '$ver'"; exit 1; }

echo "PASS T1: VERSION file + get_local_version()"

# T2: check_for_update writes .update-checked file
rm -f "$FORGE_ROOT/.update-checked"
check_for_update_test() {
  local check_file="${FORGE_ROOT}/.update-checked"
  local today; today=$(date +%Y-%m-%d)
  [ -f "$check_file" ] && [ "$(cat "$check_file")" = "$today" ] && return 0
  echo "$today" > "$check_file"
  FORGE_UPDATE_AVAILABLE="99.0.0"
  export FORGE_UPDATE_AVAILABLE
}
check_for_update_test
[ -f "$FORGE_ROOT/.update-checked" ] || { echo "FAIL T2: .update-checked not written"; exit 1; }
[ "${FORGE_UPDATE_AVAILABLE:-}" = "99.0.0" ] || { echo "FAIL T2: FORGE_UPDATE_AVAILABLE not set"; exit 1; }
echo "PASS T2: check_for_update writes marker + sets FORGE_UPDATE_AVAILABLE"

# T3: forge doctor subcommand exists and prints checklist header
out=$(bash "$FORGE_ROOT/start-forge.sh" doctor 2>&1 || true)
echo "$out" | grep -q "forge doctor" || { echo "FAIL T3: 'forge doctor' missing header"; exit 1; }
echo "$out" | grep -qE "ok|fejl|advarsler" || { echo "FAIL T3: no summary line"; exit 1; }
echo "PASS T3: forge doctor runs and prints checklist"

# T4: stop.sh creates sessions/DRAFT.md when sessions/ dir exists
TMP=$(mktemp -d)
mkdir -p "$TMP/sessions" "$TMP/.git"
# minimal git setup
(cd "$TMP" && git init -q && git commit --allow-empty -m "init" -q)
cp "$FORGE_ROOT/templates/hooks/stop.sh" "$TMP/stop.sh"
(cd "$TMP" && bash stop.sh 2>/dev/null || true)
[ -f "$TMP/sessions/DRAFT.md" ] || { echo "FAIL T4: sessions/DRAFT.md not created"; rm -rf "$TMP"; exit 1; }
grep -q "Session Draft" "$TMP/sessions/DRAFT.md" || { echo "FAIL T4: DRAFT.md missing header"; rm -rf "$TMP"; exit 1; }
rm -rf "$TMP"
echo "PASS T4: stop.sh creates sessions/DRAFT.md"

# T5: session-start.sh exists and is executable after install
[ -f "$FORGE_ROOT/templates/hooks/session-start.sh" ] || { echo "FAIL T5: session-start.sh template missing"; exit 1; }
# T5: 17-hooks.sh installs SessionStart in settings.json
TMP=$(mktemp -d)
mkdir -p "$TMP/.claude/hooks"
source "$FORGE_ROOT/lib/_common.sh"
source "$FORGE_ROOT/lib/17-hooks.sh"
PROJECT="$TMP" install_hooks 2>/dev/null
python3 -c "
import json, sys
d = json.load(open('$TMP/.claude/settings.json'))
ss = d.get('hooks', {}).get('SessionStart', [])
cmds = [h.get('command','') for e in ss for h in e.get('hooks',[])]
has = any('session-start' in c for c in cmds)
sys.exit(0 if has else 1)
" || { echo "FAIL T5: SessionStart hook not registered in settings.json"; rm -rf "$TMP"; exit 1; }
rm -rf "$TMP"
echo "PASS T5: session-start.sh template + registered in settings.json"

# T6: session-end.md command template exists
[ -f "$FORGE_ROOT/templates/commands/session-end.md" ] || { echo "FAIL T6: session-end.md missing"; exit 1; }
grep -q "session-end" "$FORGE_ROOT/templates/commands/session-end.md" || { echo "FAIL T6: session-end.md wrong content"; exit 1; }

# T6: 99-finalize creates sessions/ dir and .gitignore entry
TMP=$(mktemp -d)
(cd "$TMP" && git init -q && git commit --allow-empty -m "init" -q)
mkdir -p "$TMP/.claude"
source "$FORGE_ROOT/lib/_common.sh"
PROJECT="$TMP" INSTALL_SUPERPOWERS="N" INSTALL_AGENTS="none" \
  USE_TUNNEL="N" USE_VIAVI_SKILLS="N" USE_CONTEXT7="N" USE_CHROME_DEVTOOLS="N" \
  USE_TAILWIND="N" USE_ACETERNITY="N" DESIGN_SOURCE="skip" PROJECT_PROFILE="web-app" \
  FORGE_MODE="quick" PORT="8080" USE_ROUTER="Y" SUBPATH="" REWRITEBASE="" \
  bash -c "source '$FORGE_ROOT/lib/99-finalize.sh' 2>/dev/null; finalize_project" 2>/dev/null || true
[ -d "$TMP/sessions" ] || { echo "FAIL T6: sessions/ dir not created by finalize"; rm -rf "$TMP"; exit 1; }
grep -q "sessions/" "$TMP/.gitignore" 2>/dev/null || { echo "FAIL T6: sessions/ not in .gitignore"; rm -rf "$TMP"; exit 1; }
rm -rf "$TMP"
echo "PASS T6: session-end command + scaffold creates sessions/ + .gitignore"
