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

## Agent-orkestrering

Dette projekt bruger op til tre komplementære agent-systemer der ikke
overlapper. Hver kilde ejer sit eget domæne — ingen dubletter, ingen
modarbejdelse. Det er Forge v3.6.3's orkestreringsfilosofi.

### Workflow-disciplin · **Superpowers**

Aktiveres automatisk ved samtale-start (hvis valgt under scaffold). Tvinger
Claude igennem en Clarify → Design → Plan → Code → Verify-flow før kode
skrives. Levere disse skills og subagents:

- `brainstorming` — Socratic spørgsmål før kode
- `writing-plans` — TDD-strukturerede opgaver
- `executing-plans` — Plan-eksekvering med checkpoints
- `systematic-debugging` — 4-fase root-cause-analysis
- `red-green-refactor` — TDD-disciplin
- `code-reviewer` (subagent) — review mod planen efter implementation

### Domain-ekspertise · **Curated awesome-agents**

Kaldes eksplicit via `Task` tool når en bestemt opgave matcher. Specialister
i generelle, sprog/stack-uafhængige domæner:

- `code-reviewer` — generel code quality (erstatter Forge's tidligere)
- `security-auditor` — OWASP, auth, secrets
- `performance-engineer` — Web Vitals, bundle size, caching
- `accessibility-tester` — WCAG 2.1, keyboard nav, screen reader
- `php-pro` / `sql-pro` / `javascript-pro` / `api-designer` / m.fl.

Tilgængelige via `forge agents list`/`search`/`update`.

### Stack-specifik validering · **Forge agents**

Kaldes når PHP/SQLite/Forge-konventioner er i spil. Disse er
domænespecifikke for Forge's stack — generelle awesome-agents kender ikke
SQLite WAL-mode, Tailwind-CDN-mønstret eller Forge's schema-konventioner.

- `frontend-reviewer` — Tailwind + PHP partials, DESIGN.md-compliance
- `db-reviewer` — SQLite WAL, FK-constraints, prepared statements
- `data-integrity-auditor` — Forge schema, valuta/tidszoner ved API-data
- `browser-tester` — Chrome DevTools MCP integration (kun hvis aktiveret)
- `mcp-health-check` — Verifier Forge's MCP-config (kun hvis MCPs er sat op)

### Hvornår bruger jeg hvad?

| Situation | Agent / kilde |
|---|---|
| "Review denne PR" / "tjek koden" | Superpowers `code-reviewer` (auto efter plan) |
| Ad-hoc code review uden Superpowers | awesome `code-reviewer` |
| "Audit for sikkerhed" | awesome `security-auditor` |
| "Optimér performance" / "Web Vitals" | awesome `performance-engineer` |
| "Lav accessibility-audit" | awesome `accessibility-tester` |
| "Tjek SQLite-skemaet" / "WAL-mode" | Forge `db-reviewer` |
| "Verificer Tailwind + PHP partials" | Forge `frontend-reviewer` |
| "Test i browseren" / E2E | Forge `browser-tester` |
| "Tjek MCP-helbred" | Forge `mcp-health-check` |
| "Er PHP-koden idiomatic?" | awesome `php-pro` |
| "Optimér denne SQL-query" | awesome `sql-pro` |
| Brainstorming før et nyt modul | Superpowers `brainstorming` |
| Plan-skabelse | Superpowers `writing-plans` |
| Debugging | Superpowers `systematic-debugging` |

### Princippet

Hvis du opdager dubletter (fx både Forge `code-reviewer.md` og awesome
`code-reviewer.md`), kør `forge agents cleanup` i projektet. Forge ejer
PHP-stack-specifikt — alt andet er Superpowers eller awesome.
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
