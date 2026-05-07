# Forge v3.7.0 Enhancements — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement 8 targeted Forge improvements covering session continuity, project health, developer productivity, and release management — shipping as v3.7.0.

**Architecture:** All changes land in `~/.local/share/forge/`. New features are added as: new template files, extensions to existing lib modules, and new subcommands in `start-forge.sh`. Existing scaffold pipeline (modules 01–99) is preserved; new hooks and commands are installed by extended versions of `lib/17-hooks.sh` and `lib/11-commands.sh`.

**Tech Stack:** bash 4+, python3 (json merge, already used throughout), git

---

## File Map

**Create:**
- `VERSION` — version string `3.7.0`
- `templates/hooks/session-start.sh` — SessionStart hook: reads last session, injects context
- `templates/commands/session-end.md` — slash command: Claude writes narrative session file
- `templates/commands/new-page.md` — slash command: scaffold view skeleton
- `templates/commands/new-module.md` — slash command: scaffold module skeleton
- `templates/partials/.env.example` — base environment variable template
- `tests/scenarios/test-v370-features.sh` — test suite for all 8 features

**Modify:**
- `lib/_common.sh` — remove hardcoded `FORGE_VERSION`, add `get_local_version()`
- `start-forge.sh` — add `doctor`, `design refresh` subcommands + `check_for_update()` + `print_update_notice()`
- `templates/hooks/stop.sh` — extend with session DRAFT.md writer
- `lib/17-hooks.sh` — register SessionStart hook in settings.json
- `lib/99-finalize.sh` — create `sessions/` dir, add to `.gitignore`, copy `.env.example`
- `lib/11-commands.sh` — copy `new-page.md` and `new-module.md`
- `lib/06-design-md.sh` — extract `run_design_md()` as callable function
- `lib/16-awesome-agents.sh` — write `agents-cache-meta.json` on update, diff on list
- `templates/partials/CLAUDE.md.base` — add `.env` setup note
- `README.md` — document new features
- `CHANGELOG.md` — v3.7.0 entry

---

## Task 1: VERSION file + version helper

**Files:**
- Create: `VERSION`
- Modify: `lib/_common.sh`

- [ ] **Write failing test**

```bash
# In tests/scenarios/test-v370-features.sh — create this file:
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
```

- [ ] **Run test — expect FAIL**

```bash
bash ~/.local/share/forge/tests/scenarios/test-v370-features.sh
# Expected: FAIL T1: VERSION file missing or not semver
```

- [ ] **Create VERSION file**

```bash
echo "3.7.0" > ~/.local/share/forge/VERSION
```

- [ ] **Add `get_local_version()` to `lib/_common.sh`**

Replace line 13 (`FORGE_VERSION="${FORGE_VERSION:-3.6.4}"`) with:

```bash
get_local_version() {
  local ver_file="${FORGE_ROOT}/VERSION"
  [ -f "$ver_file" ] && tr -d '[:space:]' < "$ver_file" || echo "unknown"
}
FORGE_VERSION="${FORGE_VERSION:-$(get_local_version)}"
```

- [ ] **Run test — expect PASS**

```bash
bash ~/.local/share/forge/tests/scenarios/test-v370-features.sh
# Expected: PASS T1: VERSION file + get_local_version()
```

- [ ] **Commit**

```bash
cd ~/.local/share/forge
git add VERSION lib/_common.sh tests/scenarios/test-v370-features.sh
git commit -m "feat: add VERSION file and get_local_version() helper"
```

---

## Task 2: Auto-update check

**Files:**
- Modify: `start-forge.sh` (add `check_for_update()` and `print_update_notice()`)

- [ ] **Add test to `test-v370-features.sh`**

```bash
# T2: check_for_update writes .update-checked file
rm -f "$FORGE_ROOT/.update-checked"
# Source only the relevant function — mock curl to return higher version
_orig_curl=$(command -v curl)
check_for_update_test() {
  local check_file="${FORGE_ROOT}/.update-checked"
  local today; today=$(date +%Y-%m-%d)
  [ -f "$check_file" ] && [ "$(cat "$check_file")" = "$today" ] && return 0
  echo "$today" > "$check_file"
  # simulate finding update
  FORGE_UPDATE_AVAILABLE="99.0.0"
  export FORGE_UPDATE_AVAILABLE
}
check_for_update_test
[ -f "$FORGE_ROOT/.update-checked" ] || { echo "FAIL T2: .update-checked not written"; exit 1; }
[ "${FORGE_UPDATE_AVAILABLE:-}" = "99.0.0" ] || { echo "FAIL T2: FORGE_UPDATE_AVAILABLE not set"; exit 1; }
echo "PASS T2: check_for_update writes marker + sets FORGE_UPDATE_AVAILABLE"
```

- [ ] **Run test — expect FAIL**

```bash
bash ~/.local/share/forge/tests/scenarios/test-v370-features.sh
# Expected output includes: FAIL T2
```

- [ ] **Add functions to `start-forge.sh`** — insert after line 17 (`export FORGE_ROOT`):

```bash
# ---------------------------------------------------------------------------
# Auto-update check (max once per day, non-blocking)
# ---------------------------------------------------------------------------
FORGE_UPDATE_AVAILABLE=""
export FORGE_UPDATE_AVAILABLE

check_for_update() {
  local check_file="${FORGE_ROOT}/.update-checked"
  local today; today=$(date +%Y-%m-%d)
  [ -f "$check_file" ] && [ "$(cat "$check_file")" = "$today" ] && return 0
  echo "$today" > "$check_file"
  local local_ver; local_ver=$(get_local_version)
  local remote_ver
  remote_ver=$(curl -fsSL --max-time 3 \
    "https://raw.githubusercontent.com/viavidk/forge/main/VERSION" 2>/dev/null \
    | tr -d '[:space:]' || echo "")
  [ -n "$remote_ver" ] && [ "$remote_ver" != "$local_ver" ] && \
    FORGE_UPDATE_AVAILABLE="$remote_ver" && export FORGE_UPDATE_AVAILABLE
}

print_update_notice() {
  [ -n "${FORGE_UPDATE_AVAILABLE:-}" ] || return 0
  echo ""
  echo "  ℹ  Forge v${FORGE_UPDATE_AVAILABLE} tilgængelig — kør 'forge update'"
}
```

- [ ] **Call `check_for_update` at top of each entry point** — add `check_for_update` as the first line after the `FORCE_MODE` export block (around line 64), and add `print_update_notice` at the very end of `start-forge.sh` (before final `exit 0` if present, or just appended).

Also add after the `update` subcommand block and before `--help`:
```bash
check_for_update
```

- [ ] **Run test — expect PASS**

```bash
bash ~/.local/share/forge/tests/scenarios/test-v370-features.sh
# Expected: PASS T2: check_for_update writes marker + sets FORGE_UPDATE_AVAILABLE
```

- [ ] **Commit**

```bash
cd ~/.local/share/forge
git add start-forge.sh tests/scenarios/test-v370-features.sh
git commit -m "feat: auto-update check — notify once per day if newer version available"
```

---

## Task 3: forge doctor

**Files:**
- Modify: `start-forge.sh` (add `run_doctor()` function + `doctor` subcommand dispatch)

- [ ] **Add test to `test-v370-features.sh`**

```bash
# T3: forge doctor subcommand exists and prints checklist header
out=$(bash "$FORGE_ROOT/start-forge.sh" doctor 2>&1 || true)
echo "$out" | grep -q "forge doctor" || { echo "FAIL T3: 'forge doctor' missing header"; exit 1; }
echo "$out" | grep -qE "ok|fejl|advarsler" || { echo "FAIL T3: no summary line"; exit 1; }
echo "PASS T3: forge doctor runs and prints checklist"
```

- [ ] **Run test — expect FAIL**

```bash
bash ~/.local/share/forge/tests/scenarios/test-v370-features.sh
# Expected: FAIL T3
```

- [ ] **Add `run_doctor()` function and dispatch to `start-forge.sh`**

Add dispatch block after the `agents` block (around line 75):

```bash
if [ "${1:-}" = "doctor" ]; then
  run_doctor
  exit $?
fi
```

Add `run_doctor()` function before the `show_help()` function:

```bash
run_doctor() {
  local ok=0 warn=0 fail=0
  echo ""
  echo "  forge doctor"
  echo "  ─────────────────────────────────────────"

  _dr_ok()   { printf "  ✓  %-22s %s\n" "$1" "$2"; ok=$((ok+1)); }
  _dr_warn() { printf "  ⚠  %-22s %s\n" "$1" "$2"; warn=$((warn+1)); }
  _dr_fail() { printf "  ✗  %-22s %s\n" "$1" "$2"; fail=$((fail+1)); }

  # PHP 8.1+
  if command -v php &>/dev/null; then
    local pv; pv=$(php -r 'echo PHP_VERSION;' 2>/dev/null)
    local pm; pm=$(echo "$pv" | cut -d. -f1)
    local pn; pn=$(echo "$pv" | cut -d. -f2)
    if [ "${pm:-0}" -gt 8 ] || { [ "${pm:-0}" -eq 8 ] && [ "${pn:-0}" -ge 1 ]; }; then
      _dr_ok "PHP 8.1+" "($pv)"
    else
      _dr_fail "PHP 8.1+" "(fundet $pv — kræver 8.1+)"
    fi
  else
    _dr_fail "PHP 8.1+" "(ikke fundet)"
  fi

  # composer
  if command -v composer &>/dev/null; then
    local cv; cv=$(composer --version --no-ansi 2>/dev/null | awk '{print $3}')
    _dr_ok "composer" "($cv)"
  else
    _dr_fail "composer" "(ikke fundet)"
  fi

  # git
  if command -v git &>/dev/null; then
    local gv; gv=$(git --version 2>/dev/null | awk '{print $3}')
    _dr_ok "git" "($gv)"
  else
    _dr_fail "git" "(ikke fundet)"
  fi

  # sqlite3
  command -v sqlite3 &>/dev/null && _dr_ok "sqlite3" "tilgængelig" || _dr_fail "sqlite3" "(ikke fundet)"

  # Project-specific checks only if in a Forge project
  if [ ! -f "CLAUDE.md" ] && [ ! -f ".claude/settings.json" ]; then
    echo "  ─────────────────────────────────────────"
    echo "  (Kør fra et Forge-projektmappe for projekt-checks)"
    echo ""
    printf "  %d ok · 0 advarsler · %d fejl\n" "$ok" "$fail"
    echo ""
    [ "$fail" -eq 0 ] && return 0 || return 1
  fi

  # Hooks
  local hok=0
  for h in post-write.sh pre-bash.sh stop.sh; do
    [ -x ".claude/hooks/$h" ] && hok=$((hok+1))
  done
  if   [ "$hok" -eq 3 ]; then _dr_ok  "Hooks" "post-write · pre-bash · stop"
  elif [ "$hok" -gt 0 ]; then _dr_warn "Hooks" "$hok/3 til stede"
  else                         _dr_fail "Hooks" "alle mangler"
  fi

  # settings.json format
  if [ -f ".claude/settings.json" ]; then
    if python3 -c "
import json,sys
d=json.load(open('.claude/settings.json'))
sys.exit(0 if isinstance(d.get('enabledPlugins',{}),dict) else 1)
" 2>/dev/null; then
      _dr_ok "settings.json" "record-format ✓"
    else
      _dr_fail "settings.json" "array-format (fix: åbn 'claude .' → Fix with Claude)"
    fi
  else
    _dr_warn "settings.json" "mangler"
  fi

  # CLAUDE.md
  [ -f "CLAUDE.md" ] && _dr_ok "CLAUDE.md" "til stede" || _dr_fail "CLAUDE.md" "mangler"

  # .env
  [ -f ".env" ] && _dr_ok ".env" "til stede" || _dr_warn ".env" "mangler — kopier fra .env.example"

  # SQLite
  [ -f "database/app.sqlite" ] && _dr_ok "database/app.sqlite" "til stede" || \
    _dr_warn "database/app.sqlite" "mangler — kør /project:db-init"

  echo "  ─────────────────────────────────────────"
  printf "  %d ok · %d advarsler · %d fejl\n" "$ok" "$warn" "$fail"
  echo ""
  [ "$fail" -eq 0 ] && return 0 || return 1
}
```

- [ ] **Update `show_help()` to include doctor**

Find the line `forge update           Opdatér Forge fra GitHub` and add after it:
```bash
  echo "    forge doctor           Tjek projekt-miljøets sundhed"
```

- [ ] **Run test — expect PASS**

```bash
bash ~/.local/share/forge/tests/scenarios/test-v370-features.sh
# Expected: PASS T3
```

- [ ] **Commit**

```bash
cd ~/.local/share/forge
git add start-forge.sh tests/scenarios/test-v370-features.sh
git commit -m "feat: forge doctor — environment and project health checker"
```

---

## Task 4: Session audit — stop.sh draft writer

**Files:**
- Modify: `templates/hooks/stop.sh`

- [ ] **Add test to `test-v370-features.sh`**

```bash
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
```

- [ ] **Run test — expect FAIL**

```bash
bash ~/.local/share/forge/tests/scenarios/test-v370-features.sh
# Expected: FAIL T4
```

- [ ] **Extend `templates/hooks/stop.sh`** — append before `exit 0`:

```bash
# ── Session audit draft ───────────────────────────────────────────────────────
if [ -d "sessions" ]; then
  DRAFT="sessions/DRAFT.md"
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  TOTAL=$(git diff --name-only HEAD 2>/dev/null | wc -l | tr -d ' ')
  AUTH=$(git diff --name-only HEAD 2>/dev/null | grep -ciE 'auth|login|password|session|csrf' 2>/dev/null || echo 0)
  SCHEMA=$(git diff --name-only HEAD 2>/dev/null | grep -ciE '\.sql$|schema|migration' 2>/dev/null || echo 0)
  CHANGED_LIST=$(git diff --name-only HEAD 2>/dev/null | head -20 | sed 's/^/  - /')

  cat > "$DRAFT" <<DRAFTEOF
# Session Draft — $TS

## Ændringer siden sidste commit
- Filer ændret: $TOTAL
- Auth-relaterede: $AUTH
- Schema-relaterede: $SCHEMA

## Ændrede filer
$CHANGED_LIST

---
*Kør \`/project:session-end\` for at gemme en narrativ opsummering.*
DRAFTEOF
fi
```

- [ ] **Run test — expect PASS**

```bash
bash ~/.local/share/forge/tests/scenarios/test-v370-features.sh
# Expected: PASS T4
```

- [ ] **Commit**

```bash
cd ~/.local/share/forge
git add templates/hooks/stop.sh tests/scenarios/test-v370-features.sh
git commit -m "feat: session audit — stop hook writes DRAFT.md with git data"
```

---

## Task 5: Session audit — SessionStart hook

**Files:**
- Create: `templates/hooks/session-start.sh`
- Modify: `lib/17-hooks.sh`

- [ ] **Add test to `test-v370-features.sh`**

```bash
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
```

- [ ] **Run test — expect FAIL**

```bash
bash ~/.local/share/forge/tests/scenarios/test-v370-features.sh
# Expected: FAIL T5
```

- [ ] **Create `templates/hooks/session-start.sh`**

```bash
#!/usr/bin/env bash
# SessionStart hook — inject last session summary into Claude's context

SESSIONS_DIR="${PWD}/sessions"
[ -d "$SESSIONS_DIR" ] || exit 0

LAST=$(ls -1 "$SESSIONS_DIR"/*.md 2>/dev/null | grep -v DRAFT | sort -r | head -1)
[ -f "$LAST" ] || exit 0

FNAME=$(basename "$LAST" .md)
SUMMARY=$(head -30 "$LAST")

_esc() {
  local s="$1"
  s="${s//\\/\\\\}"; s="${s//\"/\\\"}"; s="${s//$'\n'/\\n}"; s="${s//$'\r'/\\r}"; s="${s//$'\t'/\\t}"
  printf '%s' "$s"
}

CTX="<session-context>
Forrige session ($FNAME):

$SUMMARY

Brug denne kontekst som baggrund. Spørg brugeren hvad der skal arbejdes på i dag.
</session-context>"

ESC=$(_esc "$CTX")

if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -z "${COPILOT_CLI:-}" ]; then
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$ESC"
else
  printf '{"additionalContext":"%s"}\n' "$ESC"
fi
exit 0
```

- [ ] **Make executable**

```bash
chmod +x ~/.local/share/forge/templates/hooks/session-start.sh
```

- [ ] **Add SessionStart registration to `lib/17-hooks.sh`** — in the python3 heredoc, add after the Stop block:

```python
# ── SessionStart → session-start.sh ─────────────────────────────────────────
ss = hooks.setdefault("SessionStart", [])
ss_cmd = {"type": "command", "command": "bash .claude/hooks/session-start.sh"}
ss_entry = {"matcher": "startup|clear|compact", "hooks": [ss_cmd]}
already_ss = any(
    any("session-start.sh" in hk.get("command", "") for hk in entry.get("hooks", []))
    for entry in ss
)
if not already_ss:
    ss.append(ss_entry)
```

- [ ] **Add `session-start.sh` to hook copy loop in `install_hooks()`** — in `lib/17-hooks.sh`, change:

```bash
for hook in post-write.sh pre-bash.sh stop.sh; do
```
to:
```bash
for hook in post-write.sh pre-bash.sh stop.sh session-start.sh; do
```

- [ ] **Run test — expect PASS**

```bash
bash ~/.local/share/forge/tests/scenarios/test-v370-features.sh
# Expected: PASS T5
```

- [ ] **Commit**

```bash
cd ~/.local/share/forge
git add templates/hooks/session-start.sh lib/17-hooks.sh tests/scenarios/test-v370-features.sh
git commit -m "feat: session audit — SessionStart hook injects last session context"
```

---

## Task 6: Session audit — slash command + scaffold integration

**Files:**
- Create: `templates/commands/session-end.md`
- Modify: `lib/11-commands.sh`, `lib/99-finalize.sh`

- [ ] **Add test to `test-v370-features.sh`**

```bash
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
```

- [ ] **Run test — expect FAIL**

```bash
bash ~/.local/share/forge/tests/scenarios/test-v370-features.sh
# Expected: FAIL T6
```

- [ ] **Create `templates/commands/session-end.md`**

```markdown
# /project:session-end

Afslut dagens arbejdssession og gem en narrativ opsummering.

## Steps

1. Læs `sessions/DRAFT.md` for git-data (hvilke filer, kategorier)
2. Gennemgå hvad der faktisk skete i denne session baseret på samtalen
3. Skriv en narrativ opsummering (3–8 sætninger) i naturligt sprog:
   - Hvad blev bygget, fikset eller refaktoreret
   - Vigtige tekniske beslutninger eller fund
   - Hvad der er åbent og mangler at gøre næste gang
4. Gem opsummeringen som `sessions/YYYY-MM-DD-HHMMSS.md`
   (brug faktisk tidsstempel, fx `sessions/2026-05-07-143022.md`)
5. Spørg: "Vil du tilføje en personlig note? (Enter for at springe over)"
6. Hvis brugeren skriver noget: append det til filen under overskriften `## Din note`
7. Slet `sessions/DRAFT.md` hvis den eksisterer
8. Print: "✓ Session gemt — sessions/YYYY-MM-DD-HHMMSS.md"
```

- [ ] **Add `session-end` to the commands array in `lib/11-commands.sh`**

Find the `local commands=(` array and add `session-end`:

```bash
local commands=(
    review
    fix-issue
    db-init
    new-page
    new-module
    session-end
    setup-python
    sanity-check
)
```

- [ ] **Extend `lib/99-finalize.sh`** — find the `finalize()` function body and add after the `.gitignore` block:

```bash
# Session audit directory
mkdir -p "$PROJECT/sessions"
# Add sessions/ to .gitignore if not present
if [ -f "$PROJECT/.gitignore" ]; then
  grep -q "^sessions/$" "$PROJECT/.gitignore" || echo "sessions/" >> "$PROJECT/.gitignore"
else
  echo "sessions/" > "$PROJECT/.gitignore"
fi
```

- [ ] **Run test — expect PASS**

```bash
bash ~/.local/share/forge/tests/scenarios/test-v370-features.sh
# Expected: PASS T6
```

- [ ] **Commit**

```bash
cd ~/.local/share/forge
git add templates/commands/session-end.md lib/11-commands.sh lib/99-finalize.sh \
        tests/scenarios/test-v370-features.sh
git commit -m "feat: session audit — /project:session-end command + scaffold integration"
```

---

## Task 7: Post-write test runner

**Files:**
- Modify: `templates/hooks/post-write.sh`

- [ ] **Add test to `test-v370-features.sh`**

```bash
# T7: post-write.sh contains composer test check
grep -q "composer test" "$FORGE_ROOT/templates/hooks/post-write.sh" || \
  { echo "FAIL T7: post-write.sh missing composer test runner"; exit 1; }
grep -q 'scripts.*test\|scripts.test' "$FORGE_ROOT/templates/hooks/post-write.sh" || \
  { echo "FAIL T7: post-write.sh doesn't check for composer test script"; exit 1; }
echo "PASS T7: post-write.sh has composer test runner"
```

- [ ] **Run test — expect FAIL**

```bash
bash ~/.local/share/forge/tests/scenarios/test-v370-features.sh
# Expected: FAIL T7
```

- [ ] **Extend `templates/hooks/post-write.sh`** — append before the final output block (the `if [ -n "$CONTEXT" ]` block):

```bash
# ── 4. Composer test suite ────────────────────────────────────────────────────
if [ -z "$CONTEXT" ] && echo "$FILE" | grep -qE '^src/.*\.php$'; then
  if [ -f "composer.json" ] && python3 -c "
import json,sys
d=json.load(open('composer.json'))
sys.exit(0 if 'test' in d.get('scripts',{}) else 1)
" 2>/dev/null; then
    TEST_OUT=$(composer test --no-interaction 2>&1)
    TEST_EXIT=$?
    if [ "$TEST_EXIT" -ne 0 ]; then
      CONTEXT="TEST FEJL efter ændring af $(basename "$FILE"):
$TEST_OUT
Ret fejlene inden du fortsætter."
    fi
  fi
fi
```

- [ ] **Run test — expect PASS**

```bash
bash ~/.local/share/forge/tests/scenarios/test-v370-features.sh
# Expected: PASS T7
```

- [ ] **Commit**

```bash
cd ~/.local/share/forge
git add templates/hooks/post-write.sh tests/scenarios/test-v370-features.sh
git commit -m "feat: post-write hook runs composer test when test script exists"
```

---

## Task 8: Slash commands — new-page + new-module

**Files:**
- Create: `templates/commands/new-page.md`, `templates/commands/new-module.md`
- Modify: `lib/11-commands.sh`

- [ ] **Add test to `test-v370-features.sh`**

```bash
# T8: new-page.md and new-module.md exist with correct content
[ -f "$FORGE_ROOT/templates/commands/new-page.md" ] || { echo "FAIL T8: new-page.md missing"; exit 1; }
[ -f "$FORGE_ROOT/templates/commands/new-module.md" ] || { echo "FAIL T8: new-module.md missing"; exit 1; }
grep -q "src/views" "$FORGE_ROOT/templates/commands/new-page.md" || { echo "FAIL T8: new-page.md missing views path"; exit 1; }
grep -q "src/views" "$FORGE_ROOT/templates/commands/new-module.md" || { echo "FAIL T8: new-module.md missing views path"; exit 1; }
echo "PASS T8: new-page.md and new-module.md templates exist"
```

- [ ] **Run test — expect FAIL**

```bash
bash ~/.local/share/forge/tests/scenarios/test-v370-features.sh
# Expected: FAIL T8
```

- [ ] **Create `templates/commands/new-page.md`**

```markdown
# /project:new-page

Opret en ny side i Forge-projektet.

## Brug

/project:new-page <NAVN>

Eksempel: `/project:new-page about`

## Steps

1. Bestem sidenavn fra $ARGUMENTS — brug lowercase, erstat mellemrum med bindestreg
2. Opret `src/views/<NAVN>.php`:

```php
<?php
// <NAVN> view
$title = '<NAVN>';
?>
<?php require __DIR__ . '/../includes/header.php'; ?>

<main class="container">
  <h1><?= htmlspecialchars($title) ?></h1>

  <!-- TODO: <NAVN> page content -->

</main>

<?php require __DIR__ . '/../includes/footer.php'; ?>
```

3. Print routing-linjen brugeren skal tilføje i sin router:

```php
'<NAVN>' => 'src/views/<NAVN>.php',
```

4. Informer brugeren om at tilføje routing-linjen til router-filen (typisk `src/router.php` eller `index.php`).
```

- [ ] **Create `templates/commands/new-module.md`**

```markdown
# /project:new-module

Opret et nyt modul (partial/komponent) i Forge-projektet.

## Brug

/project:new-module <NAVN>

Eksempel: `/project:new-module user-card`

## Steps

1. Bestem modulnavn fra $ARGUMENTS — brug lowercase, erstat mellemrum med bindestreg
2. Opret `src/views/<NAVN>.php`:

```php
<?php
// <NAVN> module
// Inkluder med: require __DIR__ . '/<NAVN>.php';
?>

<div class="<NAVN>">
  <!-- TODO: <NAVN> module content -->
</div>
```

3. Print include-linjen brugeren kan bruge i andre views:

```php
require __DIR__ . '/<NAVN>.php';
```
```

- [ ] **Verify `new-page` and `new-module` are already in `lib/11-commands.sh`**

```bash
grep -E "new-page|new-module" ~/.local/share/forge/lib/11-commands.sh
# Expected: both appear in the commands array — no change needed
```

- [ ] **Run test — expect PASS**

```bash
bash ~/.local/share/forge/tests/scenarios/test-v370-features.sh
# Expected: PASS T8
```

- [ ] **Commit**

```bash
cd ~/.local/share/forge
git add templates/commands/new-page.md templates/commands/new-module.md \
        lib/11-commands.sh tests/scenarios/test-v370-features.sh
git commit -m "feat: /project:new-page and /project:new-module slash commands"
```

---

## Task 9: DESIGN.md refresh

**Files:**
- Modify: `lib/06-design-md.sh`, `start-forge.sh`

- [ ] **Add test to `test-v370-features.sh`**

```bash
# T9: forge design refresh subcommand exists
out=$(bash "$FORGE_ROOT/start-forge.sh" design 2>&1 || true)
echo "$out" | grep -qi "design refresh\|forge design" || { echo "FAIL T9: 'forge design' shows no help"; exit 1; }
echo "PASS T9: forge design subcommand dispatches"
```

- [ ] **Run test — expect FAIL**

```bash
bash ~/.local/share/forge/tests/scenarios/test-v370-features.sh
# Expected: FAIL T9
```

- [ ] **Refactor `lib/06-design-md.sh`** — wrap existing install logic in `run_design_md()` function that accepts `$1` as project dir. The current top-level calls (`prompt_design_source`, `install_design_md`) stay as-is for the scaffold flow but `install_design_md` should use `${1:-$PROJECT}` for path.

Add at the bottom of `lib/06-design-md.sh`:

```bash
# Standalone entrypoint for 'forge design refresh'
design_refresh_standalone() {
  if [ ! -f "DESIGN.md" ]; then
    echo "  ✗  Ingen DESIGN.md fundet. Kør 'forge' fra et scaffoldet projekt."
    return 1
  fi
  printf "  Dette overskriver eksisterende DESIGN.md. Fortsæt? [y/N] "
  read _confirm
  [ "${_confirm:-N}" = "y" ] || [ "${_confirm:-N}" = "Y" ] || { echo "  Afbrudt."; return 0; }
  PROJECT="${PROJECT:-$PWD}"
  export PROJECT
  prompt_design_source
  install_design_md
  echo "  ✓  DESIGN.md opdateret."
}
```

- [ ] **Add `design` dispatch to `start-forge.sh`** — after the `agents` dispatch block:

```bash
if [ "${1:-}" = "design" ]; then
  shift
  case "${1:-}" in
    refresh)
      source "$FORGE_ROOT/lib/_common.sh"
      source "$FORGE_ROOT/lib/06-design-md.sh"
      PROJECT="${PWD}" export PROJECT
      design_refresh_standalone
      ;;
    *)
      echo ""
      echo "  forge design — opdatér DESIGN.md"
      echo ""
      echo "  Kommandoer:"
      echo "    forge design refresh   Vælg ny design-kilde og overskriv DESIGN.md"
      echo ""
      ;;
  esac
  exit $?
fi
```

- [ ] **Update `show_help()`** — add:

```bash
  echo "    forge design refresh   Opdatér DESIGN.md med ny kilde"
```

- [ ] **Run test — expect PASS**

```bash
bash ~/.local/share/forge/tests/scenarios/test-v370-features.sh
# Expected: PASS T9
```

- [ ] **Commit**

```bash
cd ~/.local/share/forge
git add lib/06-design-md.sh start-forge.sh tests/scenarios/test-v370-features.sh
git commit -m "feat: forge design refresh — re-run DESIGN.md selection mid-project"
```

---

## Task 10: .env.example template

**Files:**
- Create: `templates/partials/.env.example`
- Modify: `lib/99-finalize.sh`, `templates/partials/CLAUDE.md.base`

- [ ] **Add test to `test-v370-features.sh`**

```bash
# T10: .env.example template exists with required vars
[ -f "$FORGE_ROOT/templates/partials/.env.example" ] || { echo "FAIL T10: .env.example template missing"; exit 1; }
for var in APP_NAME APP_ENV APP_DEBUG DB_PATH SESSION_SECRET; do
  grep -q "$var" "$FORGE_ROOT/templates/partials/.env.example" || \
    { echo "FAIL T10: .env.example missing $var"; exit 1; }
done
echo "PASS T10: .env.example template has required variables"
```

- [ ] **Run test — expect FAIL**

```bash
bash ~/.local/share/forge/tests/scenarios/test-v370-features.sh
# Expected: FAIL T10
```

- [ ] **Create `templates/partials/.env.example`**

```env
# ViaVi Forge — environment variables
# Kopier til .env og udfyld værdier.
# COMMIT ALDRIG .env til git.

APP_NAME=my-app
APP_ENV=development
APP_DEBUG=true
DB_PATH=database/app.sqlite
SESSION_SECRET=skift-mig-til-en-tilfaeldig-lang-streng

# E-commerce / web-app med email:
# SMTP_HOST=smtp.example.com
# SMTP_PORT=587
# SMTP_USER=user@example.com
# SMTP_PASS=

# API-projekter:
# API_KEY_SALT=
```

- [ ] **Extend `lib/99-finalize.sh`** — in the finalize function, after the sessions/ block:

```bash
# .env.example
if [ -f "$FORGE_ROOT/templates/partials/.env.example" ]; then
  cp "$FORGE_ROOT/templates/partials/.env.example" "$PROJECT/.env.example"
  # Add .env to .gitignore if not present
  grep -q "^\.env$" "$PROJECT/.gitignore" 2>/dev/null || echo ".env" >> "$PROJECT/.gitignore"
fi
```

- [ ] **Add `.env` note to `templates/partials/CLAUDE.md.base`** — find the setup/getting started section and add:

```
## Environment
Kopier `.env.example` → `.env` og udfyld værdier inden du starter serveren.
`.env` er i `.gitignore` og må aldrig committes.
```

- [ ] **Run test — expect PASS**

```bash
bash ~/.local/share/forge/tests/scenarios/test-v370-features.sh
# Expected: PASS T10
```

- [ ] **Commit**

```bash
cd ~/.local/share/forge
git add templates/partials/.env.example lib/99-finalize.sh \
        templates/partials/CLAUDE.md.base tests/scenarios/test-v370-features.sh
git commit -m "feat: .env.example template with documented environment variables"
```

---

## Task 11: Agents version info

**Files:**
- Modify: `lib/16-awesome-agents.sh`

- [ ] **Add test to `test-v370-features.sh`**

```bash
# T11: forge agents list shows cache date header
# Only run if cache exists
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/forge/awesome-agents"
if [ -d "$CACHE" ]; then
  out=$(bash "$FORGE_ROOT/start-forge.sh" agents list 2>&1)
  echo "$out" | grep -qE "Agent-cache|opdateret" || { echo "FAIL T11: agents list missing cache date header"; exit 1; }
  echo "PASS T11: agents list shows cache metadata"
else
  echo "SKIP T11: agent cache not present, skipping"
fi
```

- [ ] **Run test — expect FAIL or SKIP**

```bash
bash ~/.local/share/forge/tests/scenarios/test-v370-features.sh
```

- [ ] **Add metadata write to `ensure_agents_cache()` in `lib/16-awesome-agents.sh`**

Find where `ensure_agents_cache` clones or pulls the cache. After the clone/pull succeeds, add:

```bash
# Write cache metadata
python3 - "$AGENTS_CACHE" <<'PYEOF'
import json, os, sys, datetime
cache = sys.argv[1]
meta = os.path.join(cache, 'agents-cache-meta.json')
names = sorted(
    os.path.splitext(f)[0]
    for root, dirs, files in os.walk(os.path.join(cache, 'categories'))
    for f in files
    if f.endswith('.md') and f != 'README.md'
)
with open(meta, 'w') as fh:
    json.dump({'updated': datetime.date.today().isoformat(), 'agents': names, 'count': len(names)}, fh, indent=2)
PYEOF
```

- [ ] **Add cache date header to `list` case in `forge_agents_command()`**

Before the category loop, add:

```bash
META="$AGENTS_CACHE/agents-cache-meta.json"
if [ -f "$META" ]; then
  local updated; updated=$(python3 -c "import json; print(json.load(open('$META')).get('updated','?'))" 2>/dev/null || echo "?")
  local count; count=$(python3 -c "import json; print(json.load(open('$META')).get('count','?'))" 2>/dev/null || echo "?")
  echo ""
  echo "  Agent-cache: opdateret ${updated} · ${count} agents"
  echo "  (kør 'forge agents update' for at hente seneste)"
fi
```

- [ ] **Add diff output to `update` case** — before the pull:

```bash
OLD_AGENTS=()
META="$AGENTS_CACHE/agents-cache-meta.json"
if [ -f "$META" ]; then
  mapfile -t OLD_AGENTS < <(python3 -c "
import json
for a in json.load(open('$META')).get('agents', []):
    print(a)
" 2>/dev/null)
fi
```

After pull succeeds and metadata is rewritten:

```bash
if [ ${#OLD_AGENTS[@]} -gt 0 ]; then
  NEW_AGENTS=()
  mapfile -t NEW_AGENTS < <(python3 -c "
import json
for a in json.load(open('$META')).get('agents', []):
    print(a)
" 2>/dev/null)
  ADDED=($(comm -13 <(printf '%s\n' "${OLD_AGENTS[@]}" | sort) <(printf '%s\n' "${NEW_AGENTS[@]}" | sort)))
  REMOVED=($(comm -23 <(printf '%s\n' "${OLD_AGENTS[@]}" | sort) <(printf '%s\n' "${NEW_AGENTS[@]}" | sort)))
  UNCHANGED=$(( ${#NEW_AGENTS[@]} - ${#ADDED[@]} ))
  for a in "${ADDED[@]}";   do echo "  + $a (ny)"; done
  for r in "${REMOVED[@]}"; do echo "  - $r (fjernet)"; done
  echo "  = ${UNCHANGED} uændrede"
fi
```

- [ ] **Run test — expect PASS or SKIP**

```bash
bash ~/.local/share/forge/tests/scenarios/test-v370-features.sh
```

- [ ] **Commit**

```bash
cd ~/.local/share/forge
git add lib/16-awesome-agents.sh tests/scenarios/test-v370-features.sh
git commit -m "feat: agents version info — cache date header and update diff"
```

---

## Task 12: Release artifacts

**Files:**
- Modify: `VERSION`, `start-forge.sh`, `lib/_common.sh`, `README.md`, `CHANGELOG.md`

- [ ] **Confirm VERSION is `3.7.0`** (set in Task 1 — verify):

```bash
cat ~/.local/share/forge/VERSION
# Expected: 3.7.0
```

- [ ] **Update `FORGE_VERSION` string in `start-forge.sh`** line 6:

```bash
FORGE_VERSION="3.7.0"
```

- [ ] **Update `README.md`** — update the header version badge and add to the commands table:

In the `## Kommandoer` section, add:
```
forge doctor               # Tjek projekt-miljøets sundhed
forge design refresh       # Opdatér DESIGN.md med ny kilde
```

Add a `## Session Audit` section documenting sessions/, DRAFT.md, and /project:session-end.

Add a `## Changelog` entry for v3.7.0 (see next step).

- [ ] **Update `CHANGELOG.md`** — prepend new entry:

```markdown
## v3.7.0 — 2026-05-07

### Added

- **Session audit** — Stop hook skriver `sessions/DRAFT.md` med git-data efter hvert svar. SessionStart-hook injicerer forrige sessions kontekst ved opstart. `/project:session-end` slash-kommando: Claude skriver narrativ opsummering, gemmer som `sessions/YYYY-MM-DD-HHMMSS.md`. `sessions/` er .gitignored.
- **`forge doctor`** — checker PHP 8.1+, composer, git, sqlite3, hooks, settings.json-format, CLAUDE.md, .env og database. Printer ✓/⚠/✗ pr. check. Exit code 1 ved fejl (CI-kompatibel).
- **Auto-update check** — stille check ved opstart maks én gang per dag. Printer en linje hvis ny version er tilgængelig. Fejler silently hvis offline.
- **Post-write test runner** — `post-write.sh` kører `composer test` (hvis scripts.test eksisterer) efter PHP lint. Fejl sendes som `additionalContext` til Claude.
- **`/project:new-page`** og **`/project:new-module`** — scaffold view-skeleton + routing-linje / include-linje.
- **`forge design refresh`** — genafvikler DESIGN.md-valg i eksisterende projekt. Overskriver DESIGN.md efter bekræftelse.
- **`.env.example`** — genereres ved scaffold med alle standard Forge-variabler. `.env` tilføjes til `.gitignore`.
- **Agents version info** — `forge agents list` viser dato og antal. `forge agents update` printer diff (tilføjede/fjernede agents).
- **`VERSION`-fil** — `~/.local/share/forge/VERSION` indeholder semver-streng. `check_for_update()` bruger denne til sammenligning.
```

- [ ] **Commit release artifacts**

```bash
cd ~/.local/share/forge
git add VERSION start-forge.sh README.md CHANGELOG.md
git commit -m "release: Forge v3.7.0 — session audit, doctor, auto-update + 5 productivity features"
```

---

## Task 13: End-to-end verification

- [ ] **Run full test suite**

```bash
cd ~/.local/share/forge
bash tests/scenarios/test-v370-features.sh
```
Expected: all PASS (T1–T11, no FAIL)

- [ ] **Run existing test suite — no regressions**

```bash
for f in tests/scenarios/test-*.sh; do
  bash "$f" && echo "PASS: $f" || echo "FAIL: $f"
done
```
Expected: all PASS

- [ ] **End-to-end scaffold in clean directory**

```bash
mkdir /tmp/forge-test-370 && cd /tmp/forge-test-370
FORCE_MODE=quick bash ~/.local/share/forge/start-forge.sh <<< $'my-test-app\n3\n'
```
Verify: `sessions/` exists, `.env.example` exists, `sessions/` in `.gitignore`, `.env` in `.gitignore`, `.claude/hooks/session-start.sh` exists, `.claude/commands/session-end.md` exists, `.claude/commands/new-page.md` exists.

```bash
ls sessions/ .env.example .claude/hooks/session-start.sh .claude/commands/session-end.md .claude/commands/new-page.md
grep "sessions/" .gitignore
grep "^\.env$" .gitignore
```

- [ ] **Test `forge doctor` from scaffolded project**

```bash
cd /tmp/forge-test-370/my-test-app
forge doctor
# Expected: PHP/composer/git/sqlite3 pass, .env + database warnings
```

- [ ] **Cleanup**

```bash
rm -rf /tmp/forge-test-370
```

- [ ] **Final commit if any fixes needed during verification**

```bash
cd ~/.local/share/forge
git add -A
git commit -m "fix: e2e verification fixes for v3.7.0" # only if needed
```
