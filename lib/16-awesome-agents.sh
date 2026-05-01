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
#
# Orkestrering (v3.6.3): Baseline = code-reviewer + security-auditor +
# performance-engineer fra awesome — disse erstatter Forge's tidligere
# code-reviewer/security-auditor/performance-reviewer (slettet i v3.6.3).
# Type-specifikke agents tilføjes oven på baseline.
get_recommended_agents() {
  # Baseline der ALTID installeres når INSTALL_AGENTS=recommended.
  # Erstatter Forge's 3 dropped agents.
  RECOMMENDED_AGENTS=(
    "04-quality-security/code-reviewer"
    "04-quality-security/security-auditor"
    "04-quality-security/performance-engineer"
  )

  case "${PROJECT_TYPE:-}" in
    dashboard)
      RECOMMENDED_AGENTS+=(
        "04-quality-security/accessibility-tester"
        "02-language-specialists/php-pro"
        "02-language-specialists/sql-pro"
      )
      ;;
    internal)
      RECOMMENDED_AGENTS+=(
        "04-quality-security/accessibility-tester"
        "04-quality-security/qa-expert"
        "02-language-specialists/php-pro"
      )
      ;;
    website)
      RECOMMENDED_AGENTS+=(
        "01-core-development/frontend-developer"
        "04-quality-security/accessibility-tester"
        "02-language-specialists/javascript-pro"
        "02-language-specialists/php-pro"
      )
      ;;
    ecommerce)
      RECOMMENDED_AGENTS+=(
        "01-core-development/frontend-developer"
        "02-language-specialists/php-pro"
        "02-language-specialists/sql-pro"
      )
      ;;
    api)
      RECOMMENDED_AGENTS+=(
        "01-core-development/api-designer"
        "02-language-specialists/php-pro"
        "02-language-specialists/sql-pro"
      )
      ;;
    *)
      # Ingen ekstra — baseline alene
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

# Subcommand: forge agents [list|update|search <ord>|cleanup [--apply]]
forge_agents_command() {
  local sub="${1:-}" arg="${2:-}"

  case "$sub" in
    cleanup)
      forge_agents_cleanup "$arg"
      return $?
      ;;
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
    forge agents cleanup          Detektér v3.6.2 agent-dubletter (dry-run)
    forge agents cleanup --apply  Slet Forge's gamle dublerede agents

  Cache: $AGENTS_CACHE
  Kilde: https://github.com/VoltAgent/awesome-claude-code-subagents

EOF
      ;;
  esac
}

# v3.6.3 migration: detektér og slet Forge's tidligere code-reviewer/
# security-auditor/performance-reviewer som overlapper med awesome.
# Forge-versionerne har en specifik signature i fil-headeren — det er
# sådan vi adskiller dem fra awesome-versioner med samme navn.
forge_agents_cleanup() {
  local mode="${1:-}"
  local target="${PWD}/.claude/agents"

  if [ ! -d "$target" ]; then
    echo "  ⚠  Ingen .claude/agents/ i denne mappe. Cleanup forudsætter et"
    echo "      Forge-projekt — kør kommandoen fra projektets rod."
    return 1
  fi

  # De 3 navne der potentielt har Forge-versioner fra v3.6.2 og tidligere.
  # performance-engineer er awesome's variant — Forge hed performance-reviewer.
  local check_names=("code-reviewer" "security-auditor" "performance-reviewer")

  local detected=()
  for name in "${check_names[@]}"; do
    local f="$target/${name}.md"
    [ -f "$f" ] || continue
    # Forge's egne agents er identificerbare via PHP-stack-references i
    # frontmatter description og body. Awesome-versioner er generiske.
    if grep -qE "PHP code (quality )?reviewer|vulnerabilities in PHP|PHP I/O|Strict PHP|reviewer\..*PHP|PHP-specific|code-style\.md" "$f" 2>/dev/null; then
      detected+=("$name")
    fi
  done

  if [ "${#detected[@]}" -eq 0 ]; then
    echo ""
    echo "  ✓ Ingen dublerede Forge-agents fundet i $target"
    echo "    Projektet er allerede orkestreringskonformt."
    echo ""
    return 0
  fi

  echo ""
  echo "  ${BOLD}Detekterede dubletter:${RESET}"
  for name in "${detected[@]}"; do
    echo "    ⚠  $target/$name.md (Forge-version) overlapper med awesome's $name"
  done
  echo ""
  echo "  I v3.6.3 ejer awesome generel code/security/performance-review."
  echo "  Forge ejer kun stack-specifikke agents (frontend-reviewer,"
  echo "  db-reviewer, data-integrity-auditor + browser-tester/mcp-health-check)."
  echo ""

  if [ "$mode" != "--apply" ]; then
    echo "  Anbefaling: kør ${BOLD}forge agents cleanup --apply${RESET} for at slette"
    echo "  Forge-versionerne. Awesome-versionerne installeres næste gang du"
    echo "  scaffolder med ${BOLD}INSTALL_AGENTS=recommended${RESET}, eller hent dem manuelt:"
    echo "    forge agents search code-reviewer"
    echo ""
    return 0
  fi

  # --apply: bekræft før destruktiv handling
  echo "  ${YELLOW}Følgende filer slettes:${RESET}"
  for name in "${detected[@]}"; do
    echo "    rm $target/$name.md"
  done
  echo ""
  printf "  Fortsæt? [y/N]: "
  read CONFIRM
  CONFIRM="${CONFIRM:-N}"

  if [[ "${CONFIRM,,}" != "y" ]]; then
    echo "  Annulleret. Ingen filer slettet."
    return 0
  fi

  for name in "${detected[@]}"; do
    rm -f "$target/$name.md"
    echo "  ✓ Slettet $name.md"
  done

  echo ""
  echo "  ${GREEN}Cleanup færdig.${RESET} ${#detected[@]} Forge-agents fjernet."
  echo "  Hent awesome-erstatninger med: forge agents search <navn>"
  echo ""
  return 0
}
