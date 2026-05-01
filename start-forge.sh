#!/bin/bash
# ViaVi Forge v3.6.0 — start-forge.sh
# Modulær projektgenerator for PHP/SQLite + Claude Code
set -euo pipefail

FORGE_VERSION="3.6.4"
export FORGE_VERSION

# ---------------------------------------------------------------------------
# Paths — løs symlinks så forge update virker fra ~/.local/bin/forge
# ---------------------------------------------------------------------------
_self=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || realpath "${BASH_SOURCE[0]}" 2>/dev/null || echo "${BASH_SOURCE[0]}")
FORGE_ROOT="$(cd "$(dirname "$_self")" && pwd)"
unset _self
export FORGE_ROOT

# ---------------------------------------------------------------------------
# CLI-flag: update / --help
# ---------------------------------------------------------------------------
show_help() {
  echo ""
  echo "  ViaVi Forge v$FORGE_VERSION — PHP/SQLite projektgenerator"
  echo ""
  echo "  Brug:"
  echo "    forge                  Hurtigt mode (2 spørgsmål)"
  echo "    forge --guided         Guided mode (9 trin)"
  echo "    forge --advanced       Avanceret mode (alle valg)"
  echo "    forge update           Opdatér Forge fra GitHub"
  echo "    forge agents [list|update|search <ord>]"
  echo "                           Håndter awesome-agents cache"
  echo "    forge --help           Vis denne hjælp"
  echo ""
  echo "  Genererede projekter kræver: php, composer, git"
  echo "  Mere info: https://github.com/viavidk/forge"
  echo ""
}

if [ "${1:-}" = "update" ]; then
  echo "Opdaterer Forge fra https://github.com/viavidk/forge..."
  cd "$FORGE_ROOT"
  git pull
  echo "✓ Forge er opdateret"
  exit 0
fi

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  show_help
  exit 0
fi

# Sæt mode fra flag hvis givet
if [ "${1:-}" = "--guided" ]; then
  FORCE_MODE="guided"
elif [ "${1:-}" = "--advanced" ]; then
  FORCE_MODE="advanced"
else
  FORCE_MODE=""
fi
export FORCE_MODE

# ---------------------------------------------------------------------------
# Indlæs alle lib-moduler
# ---------------------------------------------------------------------------
for lib in "$FORGE_ROOT/lib/"*.sh; do
  # shellcheck source=/dev/null
  source "$lib"
done

# ---------------------------------------------------------------------------
# Subcommand: forge agents [list|update|search <ord>]
# ---------------------------------------------------------------------------
if [ "${1:-}" = "agents" ]; then
  forge_agents_command "${2:-}" "${3:-}"
  exit $?
fi

# ---------------------------------------------------------------------------
# Initialisér tilstand
# ---------------------------------------------------------------------------
UPGRADE="false"
PROJECT=""
PORT="8080"
USE_ROUTER="Y"
SUBPATH=""
REWRITEBASE=""
USE_TUNNEL="N"
INCLUDE_UIUX="N"
USE_TAILWIND="Y"
USE_ACETERNITY="N"
DESIGN_SOURCE=""
DESIGN_TEMPLATE=""
USE_VIAVI_SKILLS="Y"
USE_CONTEXT7="Y"
USE_CHROME_DEVTOOLS="Y"
VIAVI_TOKEN=""
PROJECT_PROFILE=""
FORGE_MODE=""
UIUX_INSTALLED="N"
FRONTEND_DESIGN_INSTALLED="N"

export UPGRADE PROJECT PORT USE_ROUTER SUBPATH REWRITEBASE USE_TUNNEL
export INCLUDE_UIUX USE_TAILWIND USE_ACETERNITY DESIGN_SOURCE DESIGN_TEMPLATE
export USE_VIAVI_SKILLS USE_CONTEXT7 USE_CHROME_DEVTOOLS VIAVI_TOKEN
export PROJECT_PROFILE FORGE_MODE UIUX_INSTALLED FRONTEND_DESIGN_INSTALLED

# ---------------------------------------------------------------------------
# Velkomst
# ---------------------------------------------------------------------------
print_header

# ---------------------------------------------------------------------------
# Trin 1 — Projektnavn + eksisterende config
# ---------------------------------------------------------------------------
prompt_project_name
[ "$UPGRADE" = "true" ] && load_existing_config

# ---------------------------------------------------------------------------
# Trin 2 — Kørselstilstand (Hurtigt / Guided / Avanceret)
# ---------------------------------------------------------------------------
prompt_mode

# ---------------------------------------------------------------------------
# Trin 3 — Projekttype (kun Guided + Avanceret)
# ---------------------------------------------------------------------------
if [ "$FORGE_MODE" != "fast" ]; then
  prompt_project_type
else
  # Hurtigt mode: sane default-projekttype så smart defaults virker for v3.6.0
  PROJECT_TYPE="dashboard"
  PROJECT_PROFILE="intern"
  SUPERPOWERS_DEFAULT="Y"
  AGENTS_DEFAULT="recommended"
  export PROJECT_TYPE PROJECT_PROFILE SUPERPOWERS_DEFAULT AGENTS_DEFAULT
fi

# ---------------------------------------------------------------------------
# Trin 4 — Afhængighedstjek (basis)
# ---------------------------------------------------------------------------
check_basic_dependencies

# ---------------------------------------------------------------------------
# Trin 5 — Prompts (Guided = subset, Avanceret = alle)
# ---------------------------------------------------------------------------
if [ "$FORGE_MODE" = "fast" ]; then
  # Hurtigt: brug defaults fra projekttype (allerede sat)
  PORT="${DEFAULT_PORT:-8080}"
  USE_ROUTER="${DEFAULT_ROUTER:-Y}"
  USE_TUNNEL="${DEFAULT_TUNNEL:-N}"
  USE_ACETERNITY="${DEFAULT_ACETERNITY:-none}"
  export PORT USE_ROUTER USE_TUNNEL USE_ACETERNITY
else
  prompt_port
  prompt_routing
  prompt_cloudflare
  [ "$FORGE_MODE" = "advanced" ] && prompt_uiux
  [ "$FORGE_MODE" = "advanced" ] && prompt_tailwind
  # Aceternity: guided + advanced for website-profil, advanced også for andre
  if [ "$FORGE_MODE" = "guided" ] && [ "$PROJECT_PROFILE" = "website" ]; then
    prompt_aceternity
  elif [ "$FORGE_MODE" = "advanced" ] && [ "$USE_TAILWIND" = "Y" ]; then
    prompt_aceternity
  else
    USE_ACETERNITY="${DEFAULT_ACETERNITY:-none}"
    export USE_ACETERNITY
  fi
fi

# Cloudflare dependency-tjek — nu hvor USE_TUNNEL er sat
[ "$USE_TUNNEL" = "Y" ] && check_cloudflare_dependency

# ---------------------------------------------------------------------------
# Trin 6 — DESIGN.md kilde
# ---------------------------------------------------------------------------
prompt_design_source

# ---------------------------------------------------------------------------
# Trin 7 — MCP-servere
# ---------------------------------------------------------------------------
prompt_mcps
prompt_viavi_token

# ---------------------------------------------------------------------------
# Trin 8 — Agentic disciplin (Superpowers + curated agents)
# ---------------------------------------------------------------------------
prompt_agentic_discipline

# ---------------------------------------------------------------------------
# Trin 9 — Konfliktvalidering
# ---------------------------------------------------------------------------
validate_no_conflicts

# ---------------------------------------------------------------------------
# Byg projektet
# ---------------------------------------------------------------------------
scaffold_project_structure
scaffold_project_files
install_tailwind
install_motion_js
install_design_md
generate_mcp_config
generate_claude_md
install_agents
install_recommended_agents
install_superpowers
install_commands
install_rules
install_skills
finalize_project
print_summary
