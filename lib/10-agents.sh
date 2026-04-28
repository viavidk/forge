#!/bin/bash
# lib/10-agents.sh — installer review-agenter + browser-tester + mcp-health-check

install_agents() {
  start_spinner "Installerer review-agenter..."
  mkdir -p "$PROJECT/.claude/agents"

  # 6 eksisterende agenter fra templates
  local agents=(
    code-reviewer
    security-auditor
    frontend-reviewer
    db-reviewer
    performance-reviewer
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

  stop_spinner "Review-agenter installeret"
}
