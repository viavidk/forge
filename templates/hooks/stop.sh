#!/usr/bin/env bash
# Stop hook — session-opsummering i terminalen
#
# Vises til brugeren når Claude afslutter. Fremhæver hvis
# security- eller DB-ændringer kræver opmærksomhed.

# Kræver git
git rev-parse --git-dir &>/dev/null || exit 0

CHANGED=$(git diff --name-only HEAD 2>/dev/null | wc -l | tr -d ' ')
STAGED=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
TOTAL=$((CHANGED + STAGED))

# ── Session audit draft ───────────────────────────────────────────────────────
if [ -d "sessions" ]; then
  DRAFT="sessions/DRAFT.md"
  TS=$(date '+%Y-%m-%d %H:%M:%S')
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

[ "$TOTAL" -eq 0 ] && exit 0

SECURITY=$(git diff --name-only HEAD 2>/dev/null | grep -ciE 'auth|login|password|session|csrf' 2>/dev/null || echo 0)
SCHEMA=$(git diff --name-only HEAD 2>/dev/null | grep -ciE '\.sql$|schema|migration' 2>/dev/null || echo 0)

{
  echo ""
  echo "  ── Forge session ────────────────────────────"
  echo "  ${TOTAL} fil(er) ændret siden sidste commit"
  [ "$SECURITY" -gt 0 ] && echo "  ⚠  Auth/session-filer ændret → /project:review"
  [ "$SCHEMA"   -gt 0 ] && echo "  ⚠  DB-schema ændret → db-reviewer anbefalet"
  echo "  ─────────────────────────────────────────────"
  echo ""
} >&2

exit 0
