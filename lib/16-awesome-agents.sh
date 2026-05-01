#!/bin/bash
# lib/16-awesome-agents.sh — Awesome-Claude-Code-Subagents cache + curation (v3.6.0)
#
# VoltAgent's offentlige bibliotek af 100+ Claude Code subagents.
# Vi bevarer Forge's egne agents (PHP-tilpassede) og installerer awesome-agents
# ved siden af i samme .claude/agents/ — kun hvis de ikke kolliderer.

AGENTS_CACHE="${AGENTS_CACHE:-$HOME/.local/share/forge/awesome-claude-code-subagents}"
AGENTS_REPO="${AGENTS_REPO:-https://github.com/VoltAgent/awesome-claude-code-subagents.git}"
AGENTS_CACHE_TTL_DAYS=7

ensure_agents_cache() {
  if [ ! -d "$AGENTS_CACHE/.git" ]; then
    start_spinner "Henter agent-bibliotek (første gang)..."
    mkdir -p "$(dirname "$AGENTS_CACHE")"
    if git clone --depth 1 --quiet "$AGENTS_REPO" "$AGENTS_CACHE" 2>/dev/null; then
      stop_spinner "Agent-bibliotek hentet"
    else
      stop_spinner_err "Kunne ikke hente agent-bibliotek (offline?)"
      return 1
    fi
    return 0
  fi

  # Auto-opdatering efter $AGENTS_CACHE_TTL_DAYS dage
  if [ -n "$(find "$AGENTS_CACHE" -maxdepth 0 -mtime "+$AGENTS_CACHE_TTL_DAYS" 2>/dev/null)" ]; then
    start_spinner "Opdaterer agent-bibliotek..."
    if (cd "$AGENTS_CACHE" && git pull --quiet --depth 1 origin HEAD 2>/dev/null); then
      touch "$AGENTS_CACHE"
      stop_spinner "Agent-bibliotek opdateret"
    else
      stop_spinner_err "Kunne ikke opdatere — bruger eksisterende cache"
    fi
  fi
  return 0
}

# Curated lister pr. projekttype. Stier verificeret mod faktisk repo-struktur
# (categories/<num>-<name>/<agent>.md). Forge-projekter er PHP/SQLite — derfor
# php-pro og sql-pro overalt, ingen Node-specifikke agents som default.
get_recommended_agents() {
  case "$PROJECT_TYPE" in
    dashboard)
      RECOMMENDED_AGENTS=(
        "04-quality-security/code-reviewer"
        "04-quality-security/security-auditor"
        "04-quality-security/performance-engineer"
        "04-quality-security/accessibility-tester"
        "02-language-specialists/php-pro"
        "02-language-specialists/sql-pro"
      )
      ;;
    internal)
      RECOMMENDED_AGENTS=(
        "04-quality-security/code-reviewer"
        "04-quality-security/security-auditor"
        "04-quality-security/accessibility-tester"
        "04-quality-security/qa-expert"
        "02-language-specialists/php-pro"
        "02-language-specialists/sql-pro"
      )
      ;;
    website)
      RECOMMENDED_AGENTS=(
        "04-quality-security/code-reviewer"
        "01-core-development/frontend-developer"
        "04-quality-security/performance-engineer"
        "04-quality-security/accessibility-tester"
        "02-language-specialists/javascript-pro"
        "02-language-specialists/php-pro"
      )
      ;;
    ecommerce)
      RECOMMENDED_AGENTS=(
        "04-quality-security/code-reviewer"
        "01-core-development/frontend-developer"
        "04-quality-security/security-auditor"
        "04-quality-security/performance-engineer"
        "02-language-specialists/php-pro"
        "02-language-specialists/sql-pro"
      )
      ;;
    api)
      RECOMMENDED_AGENTS=(
        "04-quality-security/code-reviewer"
        "01-core-development/api-designer"
        "04-quality-security/security-auditor"
        "04-quality-security/performance-engineer"
        "02-language-specialists/php-pro"
        "02-language-specialists/sql-pro"
      )
      ;;
    *)
      RECOMMENDED_AGENTS=(
        "04-quality-security/code-reviewer"
        "04-quality-security/security-auditor"
      )
      ;;
  esac
}

# Installerer curated agents — kaldes fra start-forge.sh efter install_agents().
# Kollision-strategi: Forge's egne agents vinder (cp -n).
install_recommended_agents() {
  if [ "${INSTALL_AGENTS:-none}" != "recommended" ] && [ "${INSTALL_AGENTS:-none}" != "custom" ]; then
    return 0
  fi

  ensure_agents_cache || {
    echo "  ⚠  Springer awesome-agents over (cache utilgængelig)"
    return 0
  }

  get_recommended_agents
  mkdir -p "$PROJECT/.claude/agents"

  start_spinner "Installerer curated awesome-agents..."

  local installed=0 missing=0
  local sources=()
  if [ "${INSTALL_AGENTS}" = "custom" ] && [ "${#CUSTOM_AGENTS[@]:-0}" -gt 0 ]; then
    sources=("${CUSTOM_AGENTS[@]}")
  else
    sources=("${RECOMMENDED_AGENTS[@]}")
  fi

  for agent_path in "${sources[@]}"; do
    local source="$AGENTS_CACHE/categories/$agent_path.md"
    local agent_name
    agent_name=$(basename "$agent_path")
    local target="$PROJECT/.claude/agents/${agent_name}.md"

    if [ ! -f "$source" ]; then
      missing=$((missing + 1))
      continue
    fi

    # cp -n: Forge's egne agents (samme navn) vinder
    if [ ! -f "$target" ]; then
      cp "$source" "$target"
      installed=$((installed + 1))
    fi
  done

  if [ "$missing" -gt 0 ]; then
    stop_spinner_err "$installed installeret, $missing manglede i cache"
  else
    stop_spinner "$installed curated agents installeret"
  fi
}

# Subcommand: forge agents [list|update|search <ord>]
forge_agents_command() {
  local sub="${1:-}" arg="${2:-}"

  case "$sub" in
    list)
      ensure_agents_cache || return 1
      echo ""
      echo "  Tilgængelige kategorier:"
      for dir in "$AGENTS_CACHE/categories"/*/; do
        [ -d "$dir" ] || continue
        local name count
        name=$(basename "$dir")
        count=$(find "$dir" -maxdepth 1 -name '*.md' ! -name 'README.md' 2>/dev/null | wc -l)
        printf "    %s ${DIM}(%d agents)${RESET}\n" "$name" "$count"
      done
      echo ""
      echo "  Brug 'forge agents search <ord>' for at finde en specifik agent."
      echo ""
      ;;

    update)
      if [ ! -d "$AGENTS_CACHE/.git" ]; then
        ensure_agents_cache
      else
        start_spinner "Opdaterer agent-bibliotek..."
        if (cd "$AGENTS_CACHE" && git pull --quiet --depth 1 origin HEAD 2>/dev/null); then
          touch "$AGENTS_CACHE"
          stop_spinner "Agent-bibliotek opdateret"
        else
          stop_spinner_err "Kunne ikke opdatere"
          return 1
        fi
      fi
      ;;

    search)
      if [ -z "$arg" ]; then
        echo "Brug: forge agents search <søgeord>"
        return 1
      fi
      ensure_agents_cache || return 1
      echo ""
      echo "  Resultater for '$arg':"
      find "$AGENTS_CACHE/categories" -maxdepth 2 -name '*.md' ! -name 'README.md' 2>/dev/null \
        | grep -i "$arg" \
        | head -20 \
        | sed "s|$AGENTS_CACHE/categories/||; s|\.md$||; s|^|    |"
      echo ""
      ;;

    *)
      cat <<EOF

  forge agents — håndter awesome-claude-code-subagents cache

  Kommandoer:
    forge agents list             List alle kategorier
    forge agents update           Opdatér cache fra GitHub
    forge agents search <ord>     Find en agent ved navn

  Cache: $AGENTS_CACHE
  Kilde: https://github.com/VoltAgent/awesome-claude-code-subagents

EOF
      ;;
  esac
}
