#!/usr/bin/env bash
# PostToolUse hook: Write | Edit
#
# Kører efter hvert fil-gem. Output (additionalContext) sendes til Claude
# og indgår i næste svar — Claude handler proaktivt uden bruger-input.
#
# Checks:
#   1. PHP syntax-validering     → Claude ser fejlen og retter straks
#   2. Security-sensitiv fil     → Claude advares og kører security-auditor
#   3. DB-schema/migration       → Claude advares og kører db-reviewer

INPUT=$(cat)

FILE=$(echo "$INPUT" | python3 -c \
  "import json,sys; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" \
  2>/dev/null || echo "")

[ -z "$FILE" ] && exit 0

CONTEXT=""

# ── 1. PHP syntax ─────────────────────────────────────────────────────────────
if [[ "$FILE" == *.php ]]; then
  if ! LINT=$(php -l "$FILE" 2>&1); then
    CONTEXT="PHP SYNTAKSFEJL i $(basename "$FILE"):
$LINT
Ret fejlen inden du fortsætter."
  fi
fi

# Kun fortsæt med de andre checks hvis ingen syntax-fejl
if [ -z "$CONTEXT" ]; then

  BASENAME=$(basename "$FILE")

  # ── 2. Security-sensitiv fil ───────────────────────────────────────────────
  if echo "$BASENAME" | grep -qiE '^(auth|login|register|password|session|token|csrf|user|account|admin)[._-]'; then
    CONTEXT="SECURITY NOTICE: $BASENAME er auth/session-kritisk. Overvej at køre security-auditor agenten inden commit."
  elif echo "$FILE" | grep -qiE '/(auth|login|session|password|csrf)/'; then
    CONTEXT="SECURITY NOTICE: Fil i security-kritisk mappe ($BASENAME). Overvej security-auditor inden commit."
  fi

  # ── 3. DB schema/migration ────────────────────────────────────────────────
  if echo "$FILE" | grep -qiE '\.(sql)$|/migrations?/|/schema'; then
    CONTEXT="DB NOTICE: Schema-relateret fil ændret ($BASENAME). Overvej at køre db-reviewer agenten."
  fi

fi

# ── Output til Claude ─────────────────────────────────────────────────────────
if [ -n "$CONTEXT" ]; then
  python3 -c "
import json, sys
print(json.dumps({
  'hookSpecificOutput': {
    'hookEventName': 'PostToolUse',
    'additionalContext': sys.argv[1]
  }
}))
" "$CONTEXT"
fi

exit 0
