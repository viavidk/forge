#!/bin/bash
# lib/15-superpowers.sh — Superpowers plugin integration (v3.6.0)
#
# Superpowers er et Claude Code plugin (Jesse Vincent, MIT) der tilføjer 14
# skills som tvinger Claude igennem Clarify → Design → Plan → Code → Verify.
# Vi installerer kun konfigurationen — selve plugin'et auto-installeres når
# brugeren åbner projektet med `claude`.

prompt_agentic_discipline() {
  # Fast + Guided: altid fuld pakke, ingen prompt. Orkestreringen er usynlig.
  # Advanced: viser valg — power-users kan fravælge Superpowers eller agents.
  if [ "${FORGE_MODE:-guided}" != "advanced" ]; then
    INSTALL_SUPERPOWERS="${SUPERPOWERS_DEFAULT:-Y}"
    INSTALL_AGENTS="${AGENTS_DEFAULT:-recommended}"
    export INSTALL_SUPERPOWERS INSTALL_AGENTS
    return 0
  fi

  local default_choice=1
  [ "$PROJECT_PROFILE" = "backend" ] && default_choice=3

  echo ""
  echo "  ${BOLD}AI-capabilities${RESET}  ${DIM}(Advanced — fast/guided installerer altid fuld pakke)${RESET}"
  echo "  ─────────────────────────────────────────"
  echo "  [1] Fuld pakke         ${DIM}(anbefalet)${RESET}"
  echo "  [2] Kun Superpowers    ${DIM}(workflow-disciplin, ingen curated agents)${RESET}"
  echo "  [3] Kun curated agents ${DIM}(domain-eksperter, ingen workflow-tvang)${RESET}"
  echo "  [4] Ingen ekstras      ${DIM}(kun Forge stack-agents)${RESET}"
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
