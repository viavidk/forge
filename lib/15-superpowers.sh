#!/bin/bash
# lib/15-superpowers.sh — Superpowers plugin integration (v3.6.0)
#
# Superpowers er et Claude Code plugin (Jesse Vincent, MIT) der tilføjer 14
# skills som tvinger Claude igennem Clarify → Design → Plan → Code → Verify.
# Vi installerer kun konfigurationen — selve plugin'et auto-installeres når
# brugeren åbner projektet med `claude`.

prompt_agentic_discipline() {
  # Hurtigt mode: smart defaults, ingen prompt
  if [ "$FORGE_MODE" = "fast" ]; then
    INSTALL_SUPERPOWERS="${SUPERPOWERS_DEFAULT:-Y}"
    INSTALL_AGENTS="${AGENTS_DEFAULT:-recommended}"
    export INSTALL_SUPERPOWERS INSTALL_AGENTS
    return 0
  fi

  # Backend-projekter får ikke Superpowers som default — backend-folk vil ofte
  # direkte i kode uden brainstorming-flow. Curated agents er stadig nyttige.
  local default_choice=1
  if [ "$PROJECT_PROFILE" = "backend" ]; then
    default_choice=3
  fi

  echo ""
  echo "  ${BOLD}Agentic disciplin${RESET}"
  echo "  ─────────────────────────────────────────"
  echo ""
  if [ -f "$FORGE_ROOT/templates/help/superpowers.txt" ]; then
    sed 's/^/  /' "$FORGE_ROOT/templates/help/superpowers.txt"
  fi
  echo ""
  echo "  [1] Fuld pakke ${DIM}(anbefalet)${RESET}"
  echo "      Superpowers + curated awesome-agents"
  echo ""
  echo "  [2] Kun Superpowers"
  echo "      14 disciplin-skills, ingen ekstra agents"
  echo ""
  echo "  [3] Kun curated agents"
  echo "      Domain-eksperter, ingen workflow-tvang"
  echo ""
  echo "  [4] Ingen ekstras"
  echo "      Forge som i v3.5.0"
  echo ""
  printf "  Vælg [%s]: " "$default_choice"
  read DISCIPLINE_CHOICE
  DISCIPLINE_CHOICE="${DISCIPLINE_CHOICE:-$default_choice}"

  case "$DISCIPLINE_CHOICE" in
    2) INSTALL_SUPERPOWERS="Y"; INSTALL_AGENTS="none"        ;;
    3) INSTALL_SUPERPOWERS="N"; INSTALL_AGENTS="recommended" ;;
    4) INSTALL_SUPERPOWERS="N"; INSTALL_AGENTS="none"        ;;
    *) INSTALL_SUPERPOWERS="Y"; INSTALL_AGENTS="recommended" ;;
  esac

  export INSTALL_SUPERPOWERS INSTALL_AGENTS

  # v3.6.3: Forge's egne 3 generelle agents er fjernet — minimal setup giver
  # ingen code-review/security/performance-dækning. Advarsel + bekræftelse.
  warn_minimal_setup
}

# Advar når brugeren har valgt INGEN orchestration-features. Returnerer 0 hvis
# brugeren bekræfter (eller ikke er i minimal setup), eller kalder prompten
# igen hvis brugeren vil ændre valg.
warn_minimal_setup() {
  if [ "${INSTALL_SUPERPOWERS:-N}" != "N" ] || [ "${INSTALL_AGENTS:-none}" != "none" ]; then
    return 0
  fi

  echo ""
  echo "  ${YELLOW}⚠${RESET}  ${BOLD}Du har valgt ingen Superpowers og ingen curated agents.${RESET}"
  echo "      Forge's egne agents dækker ikke længere code-review,"
  echo "      security-audit eller performance — de er flyttet til"
  echo "      Superpowers/awesome i v3.6.3."
  echo ""
  echo "      Du beholder kun stack-specifikke: frontend-reviewer,"
  echo "      db-reviewer, data-integrity-auditor (+browser/MCP-health"
  echo "      hvis Chrome/MCP er konfigureret)."
  echo ""
  echo "      Anbefaling: vælg mindst [3] Kun curated agents."
  echo ""
  printf "  Fortsæt alligevel med minimal setup? [y/N]: "
  read MINIMAL_CONFIRM
  MINIMAL_CONFIRM="${MINIMAL_CONFIRM:-N}"

  if [[ "${MINIMAL_CONFIRM,,}" != "y" ]]; then
    echo "  Lad os prøve igen."
    prompt_agentic_discipline
  fi
}

# Bash-versions-tjek. Plugin selv kører via Claude Code, men prompt-flow'en i
# Superpowers bruger associative arrays.
check_superpowers_compatibility() {
  if [ "${INSTALL_SUPERPOWERS:-N}" != "Y" ]; then
    return 0
  fi
  if [ "${BASH_VERSINFO[0]:-3}" -lt 4 ]; then
    echo "  ⚠  Superpowers anbefaler bash 4+. Din: $BASH_VERSION"
    echo "     Plugin kører stadig (Claude Code har egen bash), men advarsel logges."
  fi
}

install_superpowers() {
  if [ "${INSTALL_SUPERPOWERS:-N}" != "Y" ]; then
    return 0
  fi

  start_spinner "Konfigurerer Superpowers plugin..."

  mkdir -p "$PROJECT/.claude"
  local settings="$PROJECT/.claude/settings.json"
  local marketplace_url="https://github.com/obra/superpowers-marketplace"

  # Brug python3 til at merge ind i eksisterende settings.json (eller skabe ny).
  # Korrekt Claude Code-format: enabledPlugins[] + extraKnownMarketplaces[].
  python3 - "$settings" "$marketplace_url" <<'PYEOF'
import json, os, sys

path = sys.argv[1]
url  = sys.argv[2]

if os.path.exists(path):
    try:
        with open(path) as f:
            data = json.load(f)
    except Exception:
        data = {}
else:
    data = {}

plugins = data.setdefault("enabledPlugins", [])
if "superpowers" not in plugins:
    plugins.append("superpowers")

mps = data.setdefault("extraKnownMarketplaces", [])
if not any(m.get("url") == url for m in mps if isinstance(m, dict)):
    mps.append({"url": url})

with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PYEOF

  stop_spinner "Superpowers konfigureret i .claude/settings.json"
}
