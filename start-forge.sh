#!/bin/bash
# ViaVi Forge v3.6.0 — start-forge.sh
# Modulær projektgenerator for PHP/SQLite + Claude Code
set -euo pipefail

FORGE_VERSION="3.6.6"
export FORGE_VERSION

# ---------------------------------------------------------------------------
# Paths — løs symlinks så forge update virker fra ~/.local/bin/forge
# ---------------------------------------------------------------------------
_self=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || realpath "${BASH_SOURCE[0]}" 2>/dev/null || echo "${BASH_SOURCE[0]}")
FORGE_ROOT="$(cd "$(dirname "$_self")" && pwd)"
unset _self
export FORGE_ROOT

# ---------------------------------------------------------------------------
# Auto-update check (max once per day, non-blocking)
# ---------------------------------------------------------------------------
FORGE_UPDATE_AVAILABLE=""
export FORGE_UPDATE_AVAILABLE

check_for_update() {
  local check_file="${FORGE_ROOT}/.update-checked"
  local today; today=$(date +%Y-%m-%d)
  [ -f "$check_file" ] && [ "$(cat "$check_file")" = "$today" ] && return 0
  echo "$today" > "$check_file"
  local local_ver; local_ver=$(get_local_version)
  local remote_ver
  remote_ver=$(curl -fsSL --max-time 3 \
    "https://raw.githubusercontent.com/viavidk/forge/main/VERSION" 2>/dev/null \
    | tr -d '[:space:]' || echo "")
  [ -n "$remote_ver" ] && [ "$remote_ver" != "$local_ver" ] && \
    FORGE_UPDATE_AVAILABLE="$remote_ver" && export FORGE_UPDATE_AVAILABLE
}

print_update_notice() {
  [ -n "${FORGE_UPDATE_AVAILABLE:-}" ] || return 0
  echo ""
  echo "  ℹ  Forge v${FORGE_UPDATE_AVAILABLE} tilgængelig — kør 'forge update'"
}

# ---------------------------------------------------------------------------
# forge doctor — miljø- og projektsundhedstjek
# ---------------------------------------------------------------------------
run_doctor() {
  local ok=0 warn=0 fail=0
  echo ""
  echo "  forge doctor"
  echo "  ─────────────────────────────────────────"

  _dr_ok()   { printf "  ✓  %-22s %s\n" "$1" "$2"; ok=$((ok+1)); }
  _dr_warn() { printf "  ⚠  %-22s %s\n" "$1" "$2"; warn=$((warn+1)); }
  _dr_fail() { printf "  ✗  %-22s %s\n" "$1" "$2"; fail=$((fail+1)); }

  # PHP 8.1+
  if command -v php &>/dev/null; then
    local pv; pv=$(php -r 'echo PHP_VERSION;' 2>/dev/null)
    local pm; pm=$(echo "$pv" | cut -d. -f1)
    local pn; pn=$(echo "$pv" | cut -d. -f2)
    if [ "${pm:-0}" -gt 8 ] || { [ "${pm:-0}" -eq 8 ] && [ "${pn:-0}" -ge 1 ]; }; then
      _dr_ok "PHP 8.1+" "($pv)"
    else
      _dr_fail "PHP 8.1+" "(fundet $pv — kræver 8.1+)"
    fi
  else
    _dr_fail "PHP 8.1+" "(ikke fundet)"
  fi

  # composer
  if command -v composer &>/dev/null; then
    local cv; cv=$(composer --version --no-ansi 2>/dev/null | awk '{print $3}')
    _dr_ok "composer" "($cv)"
  else
    _dr_fail "composer" "(ikke fundet)"
  fi

  # git
  if command -v git &>/dev/null; then
    local gv; gv=$(git --version 2>/dev/null | awk '{print $3}')
    _dr_ok "git" "($gv)"
  else
    _dr_fail "git" "(ikke fundet)"
  fi

  # sqlite3
  command -v sqlite3 &>/dev/null && _dr_ok "sqlite3" "tilgængelig" || _dr_fail "sqlite3" "(ikke fundet)"

  # Project-specific checks only if in a Forge project
  if [ ! -f "CLAUDE.md" ] && [ ! -f ".claude/settings.json" ]; then
    echo "  ─────────────────────────────────────────"
    echo "  (Kør fra et Forge-projektmappe for projekt-checks)"
    echo ""
    printf "  %d ok · %d advarsler · %d fejl\n" "$ok" "$warn" "$fail"
    echo ""
    [ "$fail" -eq 0 ] && return 0 || return 1
  fi

  # Hooks
  local hok=0
  for h in post-write.sh pre-bash.sh stop.sh; do
    [ -x ".claude/hooks/$h" ] && hok=$((hok+1))
  done
  if   [ "$hok" -eq 3 ]; then _dr_ok  "Hooks" "post-write · pre-bash · stop"
  elif [ "$hok" -gt 0 ]; then _dr_warn "Hooks" "$hok/3 til stede"
  else                         _dr_fail "Hooks" "alle mangler"
  fi

  # settings.json format
  if [ -f ".claude/settings.json" ]; then
    if python3 -c "
import json,sys
d=json.load(open('.claude/settings.json'))
sys.exit(0 if isinstance(d.get('enabledPlugins',{}),dict) else 1)
" 2>/dev/null; then
      _dr_ok "settings.json" "record-format ✓"
    else
      _dr_fail "settings.json" "array-format (fix: åbn 'claude .' → Fix with Claude)"
    fi
  else
    _dr_warn "settings.json" "mangler"
  fi

  # CLAUDE.md
  [ -f "CLAUDE.md" ] && _dr_ok "CLAUDE.md" "til stede" || _dr_fail "CLAUDE.md" "mangler"

  # .env
  [ -f ".env" ] && _dr_ok ".env" "til stede" || _dr_warn ".env" "mangler — kopier fra .env.example"

  # SQLite
  [ -f "database/app.sqlite" ] && _dr_ok "database/app.sqlite" "til stede" || \
    _dr_warn "database/app.sqlite" "mangler — kør /project:db-init"

  echo "  ─────────────────────────────────────────"
  printf "  %d ok · %d advarsler · %d fejl\n" "$ok" "$warn" "$fail"
  echo ""
  [ "$fail" -eq 0 ] && return 0 || return 1
}

# ---------------------------------------------------------------------------
# CLI-flag: update / --help
# ---------------------------------------------------------------------------
show_help() {
  echo ""
  echo "  ViaVi Forge v$FORGE_VERSION — PHP/SQLite projektgenerator"
  echo ""
  echo "  Brug:"
  echo "    forge                  Hurtigt mode (2 spørgsmål)"
  echo "    forge --guided         Guided mode (8 trin)"
  echo "    forge --advanced       Avanceret mode (alle valg)"
  echo "    forge update           Opdatér Forge fra GitHub"
  echo "    forge doctor           Tjek projekt-miljøets sundhed"
  echo "    forge design refresh   Opdatér DESIGN.md med ny kilde"
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

if [ "${1:-}" = "doctor" ]; then
  run_doctor
  exit $?
fi

if [ "${1:-}" = "design" ]; then
  shift
  case "${1:-}" in
    refresh)
      source "$FORGE_ROOT/lib/_common.sh"
      source "$FORGE_ROOT/lib/06-design-md.sh"
      PROJECT="${PWD}" export PROJECT
      design_refresh_standalone
      ;;
    *)
      echo ""
      echo "  forge design — opdatér DESIGN.md"
      echo ""
      echo "  Kommandoer:"
      echo "    forge design refresh   Vælg ny design-kilde og overskriv DESIGN.md"
      echo ""
      ;;
  esac
  exit $?
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

check_for_update

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

prompt_agentic_discipline   # Sætter INSTALL_SUPERPOWERS + INSTALL_AGENTS (fuld pakke, stille)

# ---------------------------------------------------------------------------
# Trin 8 — Konfliktvalidering
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
install_hooks
install_commands
install_rules
install_skills
finalize_project
print_summary
print_update_notice
