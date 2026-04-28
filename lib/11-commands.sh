#!/bin/bash
# lib/11-commands.sh — installer /project:* commands

install_commands() {
  start_spinner "Installerer project-commands..."
  mkdir -p "$PROJECT/.claude/commands"

  # Basis-commands fra templates
  local commands=(
    review
    fix-issue
    db-init
    new-page
    new-module
    setup-python
    sanity-check
  )

  for cmd in "${commands[@]}"; do
    cp "$FORGE_ROOT/templates/commands/${cmd}.md" "$PROJECT/.claude/commands/${cmd}.md"
  done

  # deploy-command med dynamiske .htaccess-linjer
  _install_deploy_command

  # /project:health — kun hvis MCP-servere er konfigureret
  if [ "$USE_VIAVI_SKILLS" = "Y" ] || [ "$USE_CONTEXT7" = "Y" ] || [ "$USE_CHROME_DEVTOOLS" = "Y" ]; then
    cp "$FORGE_ROOT/templates/commands/health.md" "$PROJECT/.claude/commands/health.md"
  fi

  stop_spinner "Project-commands installeret"
}

_install_deploy_command() {
  # deploy.md indsætter betingede .htaccess-linjer baseret på USE_ROUTER
  if [ "$USE_ROUTER" = "Y" ]; then
    local htaccess_check='4. Verify .htaccess files:
   - Root `.htaccess` blocks /app, /config, /database
   - `public/.htaccess` has correct RewriteBase'
    local htaccess_item='   - [ ] Both .htaccess files in place
   - [ ] RewriteBase matches deployment subpath'
  else
    local htaccess_check=""
    local htaccess_item=""
  fi

  cat > "$PROJECT/.claude/commands/deploy.md" << DEPLOYEOF
# /project:deploy

Verify the system is production-ready and output a deployment checklist.

## Steps

1. Run /project:review — abort if any Critical issues exist
2. Verify \`.env\` is not committed (check .gitignore)
3. Verify database/schema.sql is current
${htaccess_check:+$htaccess_check
}5. Output final checklist:
   - [ ] All secrets in .env, not in source
   - [ ] APP_DEBUG=false in production .env
${htaccess_item:+$htaccess_item
}   - [ ] SQLite file writable by web server
   - [ ] Admin password changed from default
   - [ ] composer install run on server
   - [ ] vendor/ is gitignored and not deployed via git
   - [ ] No Critical or Major review findings
DEPLOYEOF
}
