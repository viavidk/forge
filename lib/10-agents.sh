#!/bin/bash
# lib/10-agents.sh — installer Forge's stack-specifikke review-agenter
#
# Orkestrering (v3.6.3): Forge ejer KUN PHP-stack-specifikke agents.
# - Generel code-reviewer/security-auditor/performance-reviewer er flyttet
#   til Superpowers (workflow) + awesome (domain). Se forge-v3.6.3-plan.
# - Forge-stack: frontend-reviewer (Tailwind+PHP), db-reviewer (SQLite WAL),
#   data-integrity-auditor (Forge schema), browser-tester (Forge MCP),
#   mcp-health-check (Forge MCP-config).

install_agents() {
  start_spinner "Installerer Forge stack-specifikke agenter..."
  mkdir -p "$PROJECT/.claude/agents"

  # Forge ejer kun stack-specifikke — de 3 generelle (code-reviewer,
  # security-auditor, performance-reviewer) er fjernet i v3.6.3.
  local agents=(
    frontend-reviewer
    db-reviewer
    data-integrity-auditor
  )

  for agent in "${agents[@]}"; do
    cp "$FORGE_ROOT/templates/agents/${agent}.md" "$PROJECT/.claude/agents/${agent}.md"
  done

  # browser-tester (kun ved Chrome DevTools MCP)
  if [ "$USE_CHROME_DEVTOOLS" = "Y" ]; then
    cp "$FORGE_ROOT/templates/agents/browser-tester.md" "$PROJECT/.claude/agents/browser-tester.md"
    # Indsæt PORT i browser-tester
    sed -i "s/\${PORT:-8080}/${PORT:-8080}/g" "$PROJECT/.claude/agents/browser-tester.md"
  fi

  # mcp-health-check (kun hvis MCP-servere er konfigureret)
  if [ "$USE_VIAVI_SKILLS" = "Y" ] || [ "$USE_CONTEXT7" = "Y" ] || [ "$USE_CHROME_DEVTOOLS" = "Y" ]; then
    cp "$FORGE_ROOT/templates/agents/mcp-health-check.md" "$PROJECT/.claude/agents/mcp-health-check.md"
  fi

  stop_spinner "Forge stack-agenter installeret"
}
