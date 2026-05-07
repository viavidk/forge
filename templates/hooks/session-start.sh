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
