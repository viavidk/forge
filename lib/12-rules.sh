#!/bin/bash
# lib/12-rules.sh — installer .claude/rules/

install_rules() {
  start_spinner "Installerer code-rules..."
  mkdir -p "$PROJECT/.claude/rules"

  local rules=(
    code-style
    api-conventions
    testing
    javascript
    database
    data-formats
    python
    ux-laws
  )

  for rule in "${rules[@]}"; do
    cp "$FORGE_ROOT/templates/rules/${rule}.md" "$PROJECT/.claude/rules/${rule}.md"
  done

  stop_spinner "Code-rules installeret"
}
