#!/bin/bash
# lib/17-hooks.sh — Claude Code hooks installation (v3.6.6)
#
# Installerer 3 hooks i .claude/hooks/ og merger konfigurationen
# ind i .claude/settings.json. Hooks kører automatisk — ingen
# bruger-handling nødvendig.
#
#   post-write.sh  PostToolUse(Write|Edit) → PHP-lint + security/DB-notices → Claude
#   pre-bash.sh    PreToolUse(Bash)         → git commit gate ved PHP-fejl
#   stop.sh        Stop                     → session-summary i terminalen

install_hooks() {
  start_spinner "Installerer automatiske hooks..."

  local hooks_dir="$PROJECT/.claude/hooks"
  local settings="$PROJECT/.claude/settings.json"

  mkdir -p "$hooks_dir"

  # Kopiér hook-scripts fra templates
  for hook in post-write.sh pre-bash.sh stop.sh; do
    if [ -f "$FORGE_ROOT/templates/hooks/$hook" ]; then
      cp "$FORGE_ROOT/templates/hooks/$hook" "$hooks_dir/$hook"
      chmod +x "$hooks_dir/$hook"
    fi
  done

  # Merge hooks-konfiguration ind i settings.json via python3
  python3 - "$settings" <<'PYEOF'
import json, os, sys

path = sys.argv[1]

if os.path.exists(path):
    try:
        with open(path) as f:
            data = json.load(f)
    except Exception:
        data = {}
else:
    data = {}

hooks = data.setdefault("hooks", {})

# ── PostToolUse: Write|Edit → post-write.sh ───────────────────────────────────
post = hooks.setdefault("PostToolUse", [])
write_cmd = {"type": "command", "command": "bash .claude/hooks/post-write.sh"}
write_entry = {"matcher": "Write|Edit", "hooks": [write_cmd]}
if not any(h.get("matcher") == "Write|Edit" for h in post):
    post.append(write_entry)

# ── PreToolUse: Bash → pre-bash.sh ───────────────────────────────────────────
pre = hooks.setdefault("PreToolUse", [])
bash_cmd = {"type": "command", "command": "bash .claude/hooks/pre-bash.sh"}
bash_entry = {"matcher": "Bash", "hooks": [bash_cmd]}
if not any(h.get("matcher") == "Bash" for h in pre):
    pre.append(bash_entry)

# ── Stop → stop.sh ────────────────────────────────────────────────────────────
stop = hooks.setdefault("Stop", [])
stop_cmd = {"type": "command", "command": "bash .claude/hooks/stop.sh"}
stop_entry = {"hooks": [stop_cmd]}
already = any(
    any("stop.sh" in hk.get("command", "") for hk in entry.get("hooks", []))
    for entry in stop
)
if not already:
    stop.append(stop_entry)

with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PYEOF

  stop_spinner "Hooks installeret i .claude/hooks/"
}
