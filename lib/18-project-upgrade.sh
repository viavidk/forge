#!/bin/bash
# lib/18-project-upgrade.sh — forge project upgrade
#
# Opgraderer et eksisterende Forge-projekt til nyeste version.
# Kør fra projektmappen: forge project upgrade
#
# Hvad der opdateres:
#   - Hooks: tilføjer manglende (post-write, pre-bash, stop, session-start)
#             opdaterer stop.sh hvis DRAFT.md mangler (v3.7.0)
#             synkroniserer settings.json hooks-config
#   - Commands: tilføjer manglende /project:* commands
#   - CLAUDE.md: tilføjer Workspace + Agent Mesh sektioner hvis ViaVi MCP
#
# Hvad der IKKE overskrives:
#   - Eksisterende hooks (undtagen stop.sh ved version-check)
#   - Eksisterende commands (bruger kan have customiseret)
#   - CLAUDE.md-indhold (kun nye sektioner tilføjes)
#   - .env og databasefiler

run_project_upgrade() {
  local project_dir="${PWD}"
  local project_name; project_name=$(basename "$project_dir")
  local updated=0

  echo ""
  printf "  ${BOLD}forge project upgrade${RESET} — %s\n" "$project_name"
  echo "  ─────────────────────────────────────────"

  # ── Sikkerhedstjek: er vi i et Forge-projekt? ─────────────────────────
  if [ ! -f "CLAUDE.md" ] && [ ! -d ".claude" ]; then
    echo "  ${RED}✗${RESET}  Ingen Forge-projekt fundet her"
    echo "     Kør 'forge project upgrade' fra din projektmappe."
    echo ""
    exit 1
  fi

  # ── Hooks ──────────────────────────────────────────────────────────────
  local hooks_dir=".claude/hooks"
  mkdir -p "$hooks_dir"

  for hook in post-write.sh pre-bash.sh stop.sh session-start.sh; do
    local hook_path="$hooks_dir/$hook"
    local template="$FORGE_ROOT/templates/hooks/$hook"
    [ ! -f "$template" ] && continue

    if [ ! -f "$hook_path" ]; then
      cp "$template" "$hook_path"
      chmod +x "$hook_path"
      printf "  ${GREEN}✓${RESET}  Hook tilføjet:    %s\n" "$hook"
      updated=$((updated+1))
    elif [ "$hook" = "stop.sh" ] && ! grep -q "DRAFT.md" "$hook_path" 2>/dev/null; then
      cp "$template" "$hook_path"
      chmod +x "$hook_path"
      printf "  ${GREEN}✓${RESET}  Hook opdateret:   stop.sh  (session-audit + DRAFT.md, v3.7.0)\n"
      updated=$((updated+1))
    fi
  done

  # Synkronisér settings.json med hooks (tilføjer kun manglende entries)
  local settings=".claude/settings.json"
  if [ -f "$settings" ] || [ -d ".claude" ]; then
    python3 - "$settings" <<'PYEOF'
import json, os, sys

path = sys.argv[1]
if os.path.exists(path):
    try:
        data = json.load(open(path))
    except Exception:
        data = {}
else:
    data = {}

hooks = data.setdefault("hooks", {})

# PostToolUse: Write|Edit
post = hooks.setdefault("PostToolUse", [])
if not any(h.get("matcher") == "Write|Edit" for h in post):
    post.append({"matcher": "Write|Edit", "hooks": [{"type": "command", "command": "bash .claude/hooks/post-write.sh"}]})

# PreToolUse: Bash
pre = hooks.setdefault("PreToolUse", [])
if not any(h.get("matcher") == "Bash" for h in pre):
    pre.append({"matcher": "Bash", "hooks": [{"type": "command", "command": "bash .claude/hooks/pre-bash.sh"}]})

# Stop
stop = hooks.setdefault("Stop", [])
if not any(any("stop.sh" in hk.get("command","") for hk in e.get("hooks",[])) for e in stop):
    stop.append({"hooks": [{"type": "command", "command": "bash .claude/hooks/stop.sh"}]})

# SessionStart
ss = hooks.setdefault("SessionStart", [])
if not any(any("session-start.sh" in hk.get("command","") for hk in e.get("hooks",[])) for e in ss):
    ss.append({"matcher": "startup|clear|compact", "hooks": [{"type": "command", "command": "bash .claude/hooks/session-start.sh"}]})

with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PYEOF
  fi

  # ── Commands ───────────────────────────────────────────────────────────
  mkdir -p ".claude/commands"

  for cmd in review fix-issue db-init new-page new-module session-end sanity-check health; do
    local tmpl="$FORGE_ROOT/templates/commands/${cmd}.md"
    [ ! -f "$tmpl" ] && continue
    if [ ! -f ".claude/commands/${cmd}.md" ]; then
      cp "$tmpl" ".claude/commands/${cmd}.md"
      printf "  ${GREEN}✓${RESET}  Command tilføjet: /project:%s\n" "$cmd"
      updated=$((updated+1))
    fi
  done

  # ── ViaVi Workspace + Agent Mesh i CLAUDE.md ──────────────────────────
  if [ -f ".mcp.json" ] && [ -f "CLAUDE.md" ]; then
    local has_viavi
    has_viavi=$(python3 -c "
import json
d=json.load(open('.mcp.json'))
srv=d.get('mcpServers',{})
print('yes' if any('viavi' in k for k in srv) else 'no')
" 2>/dev/null || echo "no")

    if [ "$has_viavi" = "yes" ]; then
      local add_ws=false add_mesh=false
      grep -q "^## Workspace" "CLAUDE.md" || add_ws=true
      grep -q "^## Agent Mesh" "CLAUDE.md" || add_mesh=true

      if [ "$add_ws" = "true" ] || [ "$add_mesh" = "true" ]; then
        cat >> "CLAUDE.md" << WSEOF

## Workspace

workspace: ${project_name}-workspace
agent_id: claude-${project_name}

Skriv status til workspacet ved start og afslutning af opgaver:
\`workspace_write(workspace="${project_name}-workspace", key="status", value="...", agent_id="claude-${project_name}")\`

## Agent Mesh

mesh_agent: claude-${project_name}

Ved starten af hver ny session: kald \`mesh_inbox(agent_id="claude-${project_name}")\` og læs eventuelle beskeder.
Svar på ulæste mesh-beskeder inden du fortsætter med andet arbejde.
Send svar med \`mesh_send(from_agent="claude-${project_name}", to_agent="...", subject="...", body="...")\`
WSEOF
        printf "  ${GREEN}✓${RESET}  CLAUDE.md:        ViaVi Workspace + Agent Mesh tilføjet\n"
        updated=$((updated+1))
      fi
    fi
  fi

  # ── Resultat ───────────────────────────────────────────────────────────
  echo "  ─────────────────────────────────────────"
  if [ "$updated" -eq 0 ]; then
    echo "  Projektet er allerede opdateret til nyeste version ✓"
  else
    printf "  %d opdatering(er) foretaget\n" "$updated"
    echo ""
    echo "  Kør 'forge doctor' for at verificere resultatet"
  fi
  echo ""
}
