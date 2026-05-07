#!/bin/bash
# ViaVi Forge v3.6.0 — start-forge.sh
# Modulær projektgenerator for PHP/SQLite + Claude Code
set -euo pipefail

FORGE_VERSION="3.7.0"
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

  # ── Header ───────────────────────────────────────────────────────────────
  echo ""
  printf "  ${CYAN}${BOLD}███████╗ ██████╗ ██████╗  ██████╗ ███████╗${RESET}\n"
  printf "  ${CYAN}${BOLD}██╔════╝██╔═══██╗██╔══██╗██╔════╝ ██╔════╝${RESET}\n"
  printf "  ${CYAN}${BOLD}█████╗  ██║   ██║██████╔╝██║  ███╗█████╗  ${RESET}\n"
  printf "  ${CYAN}${BOLD}██╔══╝  ██║   ██║██╔══██╗██║   ██║██╔══╝  ${RESET}\n"
  printf "  ${CYAN}${BOLD}██║     ╚██████╔╝██║  ██║╚██████╔╝███████╗${RESET}\n"
  printf "  ${CYAN}${BOLD}╚═╝      ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝${RESET}\n"
  echo ""
  printf "  ${MAGENTA}${BOLD}ViaVi${RESET}${DIM} ──────────────────────────────────────${RESET}  ${BOLD}doctor  ${DIM}v${FORGE_VERSION}${RESET}\n"
  echo ""

  # ── Helpers ──────────────────────────────────────────────────────────────
  _dr_ok()   { printf "  ${GREEN}✓${RESET}  ${BOLD}%-27s${RESET}${DIM}%s${RESET}\n" "$1" "$2"; ok=$((ok+1)); }
  _dr_warn() { printf "  ${YELLOW}⚠${RESET}  ${BOLD}%-27s${RESET}%s\n" "$1" "$2"; warn=$((warn+1)); }
  _dr_fail() { printf "  ${RED}✗${RESET}  ${BOLD}%-27s${RESET}${RED}%s${RESET}\n" "$1" "$2"; fail=$((fail+1)); }
  _dr_info() { printf "  ${CYAN}ℹ${RESET}  ${DIM}%-27s%s${RESET}\n" "$1" "$2"; }

  # ── Systemmiljø ──────────────────────────────────────────────────────────
  printf "  ${WHITE}${BOLD}Systemmiljø${RESET}\n"
  printf "  ${DIM}──────────────────────────────────────────────────${RESET}\n"

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
    _dr_fail "composer" "(ikke fundet — installer med: curl -sS https://getcomposer.org/installer | php -- --install-dir=\$HOME/.local/bin --filename=composer)"
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

  # node / npx (kræves af Context7 og Chrome DevTools MCP)
  if command -v node &>/dev/null; then
    local nv; nv=$(node --version 2>/dev/null)
    _dr_ok "node / npx" "($nv)"
  else
    _dr_warn "node / npx" "(ikke fundet — kræves af Context7 + Chrome DevTools MCP)"
  fi

  # cloudflared (valgfrit — kræves af Tunnel)
  if command -v cloudflared &>/dev/null; then
    local clv; clv=$(cloudflared --version 2>/dev/null | awk '{print $3}')
    _dr_ok "cloudflared" "($clv)"
  else
    _dr_warn "cloudflared" "(ikke fundet — kræves kun ved Cloudflare Tunnel)"
  fi

  # Project-specific checks only if in a Forge project
  if [ ! -f "CLAUDE.md" ] && [ ! -f ".claude/settings.json" ]; then
    echo ""
    printf "  ${DIM}──────────────────────────────────────────────────${RESET}\n"
    printf "  ${DIM}Kør fra en Forge-projektmappe for projekt-checks${RESET}\n"
    echo ""
    _dr_summary "$ok" "$warn" "$fail"
    [ "$fail" -eq 0 ] && return 0 || return 1
  fi

  # ── Projekt ───────────────────────────────────────────────────────────────
  echo ""
  local pname; pname=$(basename "${PWD}")
  printf "  ${WHITE}${BOLD}Projekt${RESET}  ${DIM}— %s${RESET}\n" "$pname"
  printf "  ${DIM}──────────────────────────────────────────────────${RESET}\n"

  # Hooks (4 forventet: post-write, pre-bash, stop, session-start)
  local hok=0 hmissing=()
  for h in post-write.sh pre-bash.sh stop.sh session-start.sh; do
    if [ -f ".claude/hooks/$h" ]; then
      hok=$((hok+1))
    else
      hmissing+=("$h")
    fi
  done
  if [ "$hok" -eq 4 ]; then
    _dr_ok "Hooks (4/4)" "post-write · pre-bash · stop · session-start"
  elif [ "$hok" -eq 3 ] && [[ " ${hmissing[*]} " == *" session-start.sh "* ]]; then
    _dr_warn "Hooks (3/4)" "session-start mangler — kør 'forge project upgrade'"
  elif [ "$hok" -gt 0 ]; then
    _dr_warn "Hooks ($hok/4)" "mangler: ${hmissing[*]} — kør 'forge project upgrade'"
  else
    _dr_fail "Hooks" "alle mangler — kør 'forge project upgrade'"
  fi

  # settings.json + Superpowers
  if [ -f ".claude/settings.json" ]; then
    local sp_status
    sp_status=$(python3 -c "
import json,sys
d=json.load(open('.claude/settings.json'))
ep=d.get('enabledPlugins',{})
fmt_ok=isinstance(ep,dict)
sp=any('superpowers' in k for k in ep)
print('fmt_ok=' + str(fmt_ok))
print('superpowers=' + str(sp))
" 2>/dev/null || echo "fmt_ok=False")
    if echo "$sp_status" | grep -q "fmt_ok=False"; then
      _dr_fail "settings.json" "array-format — fix: åbn 'claude .' og bed Claude rette det"
    else
      _dr_ok "settings.json" "record-format ✓"
      if echo "$sp_status" | grep -q "superpowers=True"; then
        _dr_ok "Superpowers" "aktiveret ✓"
      else
        _dr_warn "Superpowers" "ikke aktiveret — kør 'forge' og vælg Superpowers"
      fi
    fi
  else
    _dr_warn "settings.json" "mangler"
  fi

  # Agents
  if [ -d ".claude/agents" ]; then
    local agent_count; agent_count=$(ls ".claude/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
    if [ "$agent_count" -gt 0 ]; then
      _dr_ok "Agents" "($agent_count installeret)"
    else
      _dr_warn "Agents" "ingen — kør 'forge agents update'"
    fi
  else
    _dr_warn "Agents" "ingen — kør 'forge agents update'"
  fi

  # Skills
  if [ -d ".claude/skills" ]; then
    local skill_names=()
    for sd in ".claude/skills"/*/; do
      [ -d "$sd" ] && skill_names+=("$(basename "$sd")")
    done
    local skill_count=${#skill_names[@]}
    if [ "$skill_count" -gt 0 ]; then
      _dr_ok "Skills" "($skill_count: $(IFS=', '; echo "${skill_names[*]}"))"
    else
      _dr_info "Skills" "ingen installeret"
    fi
  else
    _dr_info "Skills" "ingen installeret"
  fi

  # MCP-servere
  if [ -f ".mcp.json" ]; then
    local mcp_result
    mcp_result=$(python3 -c "
import json
d=json.load(open('.mcp.json'))
srv=d.get('mcpServers',{})

# Context7 og Chrome DevTools
print('context7=' + ('ok' if 'context7' in srv else 'missing'))
print('chrome=' + ('ok' if 'chrome-devtools' in srv else 'missing'))

# ViaVi: acceptér viavi-skills eller viavi-forge
viavi_key = next((k for k in srv if 'viavi' in k), None)
if viavi_key:
    entry = srv[viavi_key]
    # Bearer token i headers
    auth = entry.get('headers', {}).get('Authorization', '')
    token = auth.replace('Bearer ', '').strip()
    # URL-token fallback (ældre format)
    if not token:
        import re
        url = entry.get('url', '')
        m = re.search(r'token=([^&\s]+)', url)
        token = m.group(1) if m else ''
    if token and token not in (r'\${VIAVI_TOKEN}', 'YOUR_VIAVI_TOKEN_HERE', ''):
        print('viavi=ok')
        print('viavi_token=set')
    else:
        print('viavi=ok')
        print('viavi_token=empty')
else:
    print('viavi=missing')
    print('viavi_token=none')
" 2>/dev/null || echo -e "context7=missing\nchrome=missing\nviavi=missing\nviavi_token=none")

    local mcp_c7 mcp_ch mcp_vi mcp_tok
    mcp_c7=$(echo "$mcp_result" | grep "^context7=" | cut -d= -f2)
    mcp_ch=$(echo "$mcp_result" | grep "^chrome=" | cut -d= -f2)
    mcp_vi=$(echo "$mcp_result" | grep "^viavi=" | cut -d= -f2)
    mcp_tok=$(echo "$mcp_result" | grep "^viavi_token=" | cut -d= -f2)

    # ViaVi Skills + token
    if [ "$mcp_vi" = "ok" ]; then
      if [ "$mcp_tok" = "set" ]; then
        _dr_ok "MCP: ViaVi Skills" "konfigureret · token ✓"
      else
        _dr_warn "MCP: ViaVi Skills" "konfigureret men token mangler — tjek .mcp.json"
      fi
      # Workspace + Mesh i CLAUDE.md?
      if grep -q "^## Workspace" "CLAUDE.md" 2>/dev/null && grep -q "^## Agent Mesh" "CLAUDE.md" 2>/dev/null; then
        _dr_ok "ViaVi Workspace/Mesh" "konfigureret i CLAUDE.md ✓"
      else
        _dr_warn "ViaVi Workspace/Mesh" "mangler i CLAUDE.md — kør 'forge project upgrade'"
      fi
    else
      _dr_info "MCP: ViaVi Skills" "ikke konfigureret — kør 'forge' og vælg ViaVi Skills"
    fi

    # Context7 og Chrome DevTools (valgfrie — info hvis de mangler)
    [ "$mcp_c7" = "ok" ] && _dr_ok "MCP: Context7" "konfigureret ✓" || _dr_info "MCP: Context7" "ikke valgt"
    [ "$mcp_ch" = "ok" ] && _dr_ok "MCP: Chrome DevTools" "konfigureret ✓" || _dr_info "MCP: Chrome DevTools" "ikke valgt"
  else
    _dr_warn "MCP (.mcp.json)" "mangler — kør 'forge' i projektmappen"
  fi

  # CLAUDE.md
  [ -f "CLAUDE.md" ] && _dr_ok "CLAUDE.md" "til stede" || _dr_fail "CLAUDE.md" "mangler"

  # DESIGN.md (valgfrit — ui-ux-pro-max skill ejer den, eller statisk fil)
  if [ -f "DESIGN.md" ]; then
    _dr_ok "DESIGN.md" "til stede"
  elif [ -f ".claude/skills/ui-ux-pro-max/SKILL.md" ]; then
    _dr_ok "DESIGN.md" "styret af ui-ux-pro-max skill ✓"
  elif grep -q "DESIGN.md" "CLAUDE.md" 2>/dev/null; then
    _dr_warn "DESIGN.md" "mangler men refereret i CLAUDE.md — kør 'forge design refresh'"
  else
    _dr_info "DESIGN.md" "ikke valgt — kør 'forge design refresh' for at tilføje"
  fi

  # .env
  [ -f ".env" ] && _dr_ok ".env" "til stede" || _dr_warn ".env" "mangler — kopier fra .env.example"

  # SQLite
  [ -f "database/app.sqlite" ] && _dr_ok "database/app.sqlite" "til stede" || \
    _dr_warn "database/app.sqlite" "mangler — kør /project:db-init"

  echo ""
  _dr_summary "$ok" "$warn" "$fail"
  [ "$fail" -eq 0 ] && return 0 || return 1
}

_dr_summary() {
  local ok=$1 warn=$2 fail=$3
  printf "  ${DIM}══════════════════════════════════════════════════${RESET}\n"
  if [ "$fail" -eq 0 ] && [ "$warn" -eq 0 ]; then
    printf "  ${GREEN}${BOLD}✦  Alle systemer OK${RESET}  ${DIM}·  %d ok${RESET}\n" "$ok"
  elif [ "$fail" -eq 0 ]; then
    printf "  ${GREEN}${BOLD}%d ok${RESET}  ${DIM}·${RESET}  ${YELLOW}${BOLD}%d advarsel(er)${RESET}  ${DIM}·  0 fejl${RESET}\n" "$ok" "$warn"
  else
    printf "  ${GREEN}%d ok${RESET}  ${DIM}·${RESET}  ${YELLOW}%d advarsel(er)${RESET}  ${DIM}·${RESET}  ${RED}${BOLD}%d fejl${RESET}\n" "$ok" "$warn" "$fail"
  fi
  echo ""
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
  echo "    forge update           Opdatér Forge-værktøjet fra GitHub"
  echo "    forge project upgrade  Opgradér projekt til nyeste version"
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
  echo ""
  echo "  Tip: kør 'forge project upgrade' i dit projekt for at opdatere"
  echo "       hooks, commands og CLAUDE.md til nyeste version."
  exit 0
fi

if [ "${1:-}" = "project" ] && [ "${2:-}" = "upgrade" ]; then
  source "$FORGE_ROOT/lib/_common.sh"
  source "$FORGE_ROOT/lib/18-project-upgrade.sh"
  run_project_upgrade
  exit $?
fi

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  show_help
  exit 0
fi

if [ "${1:-}" = "doctor" ]; then
  source "$FORGE_ROOT/lib/_common.sh"
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
