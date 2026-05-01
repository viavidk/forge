#!/usr/bin/env bash
# PreToolUse hook: Bash
#
# Blokerer `git commit` hvis staged PHP-filer har syntax-fejl.
# Claude ser blokeringen, retter fejlene og forsøger commit igen.

INPUT=$(cat)

CMD=$(echo "$INPUT" | python3 -c \
  "import json,sys; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" \
  2>/dev/null || echo "")

# Kun relevant ved git commit
echo "$CMD" | grep -q "git commit" || exit 0

# Kræver at vi er i et git-repo
git rev-parse --git-dir &>/dev/null || exit 0

ERRORS=0
MESSAGES=""

while IFS= read -r file; do
  [[ "$file" != *.php ]] && continue
  [ -f "$file" ] || continue
  if ! RESULT=$(php -l "$file" 2>&1); then
    MESSAGES="${MESSAGES}  ${RESULT}\n"
    ERRORS=$((ERRORS + 1))
  fi
done < <(git diff --cached --name-only 2>/dev/null)

if [ "$ERRORS" -gt 0 ]; then
  REASON="COMMIT BLOKERET: ${ERRORS} PHP-syntaksfejl i staged files:
$(printf "%b" "$MESSAGES")
Ret fejlene og stage dem igen inden commit."

  python3 -c "
import json, sys
print(json.dumps({
  'hookSpecificOutput': {
    'hookEventName': 'PreToolUse',
    'permissionDecision': 'deny',
    'permissionDecisionReason': sys.argv[1]
  }
}))
" "$REASON"
  exit 0
fi

exit 0
