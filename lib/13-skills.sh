#!/bin/bash
# lib/13-skills.sh — installer .claude/skills/

install_skills() {
  start_spinner "Installerer skills..."
  mkdir -p "$PROJECT/.claude/skills"

  # SKILL.md index
  cp "$FORGE_ROOT/templates/skills/SKILL.md" "$PROJECT/.claude/skills/SKILL.md"

  # 4 core skills
  local skills=(security-review deploy pre-commit document)
  for skill in "${skills[@]}"; do
    mkdir -p "$PROJECT/.claude/skills/$skill"
    cp "$FORGE_ROOT/templates/skills/$skill/README.md" "$PROJECT/.claude/skills/$skill/README.md"
  done

  stop_spinner "Skills installeret"
}
