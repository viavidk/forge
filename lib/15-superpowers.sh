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

  mkdir -p "$PROJECT/.claude" "$PROJECT/.claude-plugin"

  if [ -f "$FORGE_ROOT/templates/partials/plugins.json.template" ]; then
    cp "$FORGE_ROOT/templates/partials/plugins.json.template" "$PROJECT/.claude/plugins.json"
  fi
  if [ -f "$FORGE_ROOT/templates/partials/marketplace.json.template" ]; then
    cp "$FORGE_ROOT/templates/partials/marketplace.json.template" "$PROJECT/.claude-plugin/marketplace.json"
  fi

  stop_spinner "Superpowers konfigureret (auto-installeres ved første \`claude\`-start)"
}
