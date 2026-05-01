#!/bin/bash
# lib/09-claude-md.sh — CLAUDE.md + PROJECT.md + CLAUDE.local.md generering

generate_claude_md() {
  start_spinner "Genererer Claude-konfiguration..."

  # Base CLAUDE.md
  cp "$FORGE_ROOT/templates/partials/CLAUDE.md.base" "$PROJECT/CLAUDE.md"

  # ui-ux-pro-max installation (kører FØR UIUX_ON/UIUX_OFF appendes)
  install_uiux_skill

  # Betinget UIUX-sektion
  if [[ "$INCLUDE_UIUX" == "Y" ]] && [[ "$UIUX_INSTALLED" == "Y" ]]; then
    cat "$FORGE_ROOT/templates/partials/CLAUDE.md.uiux-on" >> "$PROJECT/CLAUDE.md"
  else
    cat "$FORGE_ROOT/templates/partials/CLAUDE.md.uiux-off" >> "$PROJECT/CLAUDE.md"
    # frontend-design skill
    install_frontend_design_skill
    if [[ "$FRONTEND_DESIGN_INSTALLED" == "Y" ]]; then
      cat "$FORGE_ROOT/templates/partials/CLAUDE.md.frontend-design" >> "$PROJECT/CLAUDE.md"
    fi
  fi

  # Tailwind-sektion
  if [[ "$USE_TAILWIND" == "Y" ]]; then
    cat "$FORGE_ROOT/templates/partials/CLAUDE.md.tailwind-on" >> "$PROJECT/CLAUDE.md"
  else
    cat "$FORGE_ROOT/templates/partials/CLAUDE.md.tailwind-off" >> "$PROJECT/CLAUDE.md"
  fi

  # Design token hint for non-Apple design systems
  if [ -n "$DESIGN_TEMPLATE" ] && [ "$DESIGN_TEMPLATE" != "apple" ] && [ "$USE_TAILWIND" = "Y" ]; then
    cat >> "$PROJECT/CLAUDE.md" << TOKENEOF

## Tailwind Token Convention

This project uses the ${DESIGN_TEMPLATE} design system.
Tailwind tokens are prefixed with \`ds-\`. Always prefer named tokens over arbitrary hex values:

| Token | Tailwind class | Use |
|-------|---------------|-----|
| Accent | \`bg-ds-accent\` / \`text-ds-accent\` | Primary CTA, links, focus rings |
| Dark bg | \`bg-ds-bg-dark\` | Dark section backgrounds |
| Light bg | \`bg-ds-bg-light\` | Light section backgrounds |
| Dark text | \`text-ds-tx-dark\` | Text on dark backgrounds |
| Light text | \`text-ds-tx-light\` | Text on light backgrounds |
| Surface | \`bg-ds-surface\` | Cards, panels on dark bg |
| Muted | \`text-ds-muted\` | Secondary/helper text |
| Border | \`border-ds-border\` | Dividers, card borders |
| Sans font | \`font-ds-sans\` | Body and heading text |

Do NOT use arbitrary values like \`bg-[#635bff]\` — use \`bg-ds-accent\` instead.
TOKENEOF
  fi

  # MCP-reference hvis ViaVi Skills er aktiv
  if [ "$USE_VIAVI_SKILLS" = "Y" ]; then
    cat >> "$PROJECT/CLAUDE.md" << 'MCPMD'

## MCP-servere

Dette projekt bruger ViaVi Skills via `.mcp.json`.
Skills hentes automatisk ved opstart af Claude Code.
MCPMD
  fi

  # v3.6.3: Orkestrering (kun hvis Superpowers og/eller awesome-agents er valgt)
  generate_orchestration_section

  stop_spinner "Claude-konfiguration genereret"
}

# Indsætter agent-orkestrerings-guide i CLAUDE.md når mindst ét orchestration-
# system er aktivt. Forklarer "hvilken kilde ejer hvad" så Claude Code i
# projektet ved hvilken agent der bruges hvornår.
generate_orchestration_section() {
  local has_sp="${INSTALL_SUPERPOWERS:-N}"
  local has_ag="${INSTALL_AGENTS:-none}"

  if [ "$has_sp" != "Y" ] && [ "$has_ag" = "none" ]; then
    return 0
  fi

  cat >> "$PROJECT/CLAUDE.md" << 'ORCHEOF'

## AI-capabilities

Dette projekt har følgende agents installeret. Brug dem aktivt.

**Workflow-disciplin** (auto-aktiveres ved samtale-start):
`brainstorming`, `writing-plans`, `executing-plans`, `systematic-debugging`,
`red-green-refactor`, `code-reviewer` (subagent efter implementation)

**Kvalitetssikring** (kald via Task tool):
`security-auditor`, `performance-engineer`, `accessibility-tester`,
`php-pro`, `sql-pro` — og evt. type-specifikke agents

**Stack-validering** (kald ved PHP/SQLite/Forge-specifikke situationer):
`frontend-reviewer`, `db-reviewer`, `data-integrity-auditor`,
`browser-tester`, `mcp-health-check`

**Automatiske hooks** (kører uden bruger-handling):
- Hvert `.php`-fil-gem: syntax-tjek, fejl sendes som context
- Auth/login/session-filer: security-notice sendes som context
- `git commit`: blokeres ved PHP-syntaksfejl i staged files
ORCHEOF
}

install_uiux_skill() {
  UIUX_INSTALLED="N"
  [ "$INCLUDE_UIUX" != "Y" ] && return

  start_spinner "Installerer ui-ux-pro-max design skill..."

  # Forsøg 1: lokal cache
  if [ -d "$HOME/.claude/skills/ui-ux-pro-max" ] && [ -f "$HOME/.claude/skills/ui-ux-pro-max/SKILL.md" ]; then
    mkdir -p "$PROJECT/.claude/skills/ui-ux-pro-max"
    cp -r "$HOME/.claude/skills/ui-ux-pro-max/." "$PROJECT/.claude/skills/ui-ux-pro-max/"
    UIUX_INSTALLED="Y"
    stop_spinner "ui-ux-pro-max hentet fra lokal cache"
    export UIUX_INSTALLED; return
  fi

  # Forsøg 2: uipro-cli
  if command -v uipro &>/dev/null; then
    if (cd "$PROJECT" && timeout 30 uipro init --ai claude --force --offline </dev/null >/dev/null 2>&1) && [ -f "$PROJECT/.claude/skills/ui-ux-pro-max/SKILL.md" ]; then
      UIUX_INSTALLED="Y"
      stop_spinner "ui-ux-pro-max installeret via uipro-cli"
      export UIUX_INSTALLED; return
    fi
  fi

  kill_spinner

  # Forsøg 3: npm install uipro-cli
  if command -v npm &>/dev/null; then
    start_spinner "Installerer uipro-cli globalt via npm..."
    if timeout 60 npm install -g uipro-cli >/dev/null 2>&1 && command -v uipro &>/dev/null; then
      if (cd "$PROJECT" && timeout 30 uipro init --ai claude --force --offline </dev/null >/dev/null 2>&1) && [ -f "$PROJECT/.claude/skills/ui-ux-pro-max/SKILL.md" ]; then
        UIUX_INSTALLED="Y"
        stop_spinner "uipro-cli + ui-ux-pro-max installeret"
        export UIUX_INSTALLED; return
      fi
    fi
    stop_spinner_err "npm install af uipro-cli fejlede"
  fi

  kill_spinner
  INCLUDE_UIUX="N"
  echo "  ⚠  ui-ux-pro-max kunne ikke installeres — projektet fortsætter uden skill'en"
  echo "     Installér manuelt: npm install -g uipro-cli && cd $PROJECT && uipro init --ai claude"
  export UIUX_INSTALLED INCLUDE_UIUX
}

install_frontend_design_skill() {
  FRONTEND_DESIGN_INSTALLED="N"
  [ "$INCLUDE_UIUX" = "Y" ] && return
  # I Hurtigt-mode: spring git clone over for at holde ~10s-målet
  [ "$FORGE_MODE" = "fast" ] && export FRONTEND_DESIGN_INSTALLED && return

  start_spinner "Installerer Anthropic frontend-design skill..."

  # Forsøg 1: lokal cache
  if [ -d "$HOME/.claude/skills/frontend-design" ] && [ -f "$HOME/.claude/skills/frontend-design/SKILL.md" ]; then
    mkdir -p "$PROJECT/.claude/skills/frontend-design"
    cp -r "$HOME/.claude/skills/frontend-design/." "$PROJECT/.claude/skills/frontend-design/"
    FRONTEND_DESIGN_INSTALLED="Y"
    stop_spinner "frontend-design hentet fra lokal cache"
    export FRONTEND_DESIGN_INSTALLED; return
  fi

  # Forsøg 2: git clone
  if command -v git &>/dev/null; then
    local TMP_CLONE
    TMP_CLONE=$(mktemp -d)
    if timeout 30 git clone --depth 1 --quiet https://github.com/anthropics/skills.git "$TMP_CLONE" 2>/dev/null && [ -d "$TMP_CLONE/skills/frontend-design" ]; then
      mkdir -p "$PROJECT/.claude/skills/frontend-design"
      cp -r "$TMP_CLONE/skills/frontend-design/." "$PROJECT/.claude/skills/frontend-design/"
      FRONTEND_DESIGN_INSTALLED="Y"
      stop_spinner "frontend-design klonet fra GitHub"
      rm -rf "$TMP_CLONE"
      export FRONTEND_DESIGN_INSTALLED; return
    fi
    rm -rf "$TMP_CLONE"
  fi

  stop_spinner_err "frontend-design kunne ikke installeres — projektet fortsætter uden"
  export FRONTEND_DESIGN_INSTALLED
}

generate_project_md() {
  [ -f "$PROJECT/PROJECT.md" ] && return

  cat > "$PROJECT/PROJECT.md" << PROJECTEOF
# $PROJECT

## Hvad systemet gør
[Beskriv hvad systemet gør og hvem det er til — opdateres af Claude efter første modul er bygget]

## Sider og routes

| Route | Controller | Beskrivelse | Auth krævet |
|-------|-----------|-------------|-------------|
| /     | —         | Velkomstside (erstattes) | Nej |

## Databaseskema

| Tabel     | Nøglekolonner              | Relationer |
|-----------|---------------------------|------------|
| users     | id, email, password, role | —          |
| api_logs  | id, service, endpoint, status_code | — |

## Eksterne integrationer

Ingen endnu.

## Arkitekturbeslutninger

- PHP/SQLite valgt frem for MySQL: simplere deployment til Apache uden ekstern databaseserver.
- MVC uden framework: fuld kontrol, ingen afhængigheder, lettere for AI-agenter at navigere.

## Teknisk gæld

Ingen kendte endnu.

## Sidst opdateret

Oprettet af ViaVi Forge v${FORGE_VERSION} · Ingen moduler bygget endnu.
PROJECTEOF
}

generate_claude_local_md() {
  [ -f "$PROJECT/CLAUDE.local.md" ] && return
  cat > "$PROJECT/CLAUDE.local.md" << 'EOF'
# CLAUDE.local.md — personlige overrides (gitignored)

<!-- Eksempler:
- Foretrukne sprog i output
- Lokale test-credentials
- Personlige værktøjspræferencer
-->
EOF
}
