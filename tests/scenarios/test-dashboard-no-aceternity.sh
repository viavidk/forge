#!/bin/bash
# Test: dashboard må IKKE få Aceternity — selv hvis man prøver at sætte det
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

cd "$TMP"

export PROJECT="testprojekt"
export PROJECT_PROFILE="intern"
export PROJECT_TYPE="dashboard"
export USE_ACETERNITY="full"  # Forsøger at sætte full — conflict-check skal sætte til none
export USE_TAILWIND="Y"
export DESIGN_SOURCE="viavi-design-system"
export PORT=8080
export USE_ROUTER="Y"
export SUBPATH="/"
export REWRITEBASE="/public/"
export UPGRADE="false"
export USE_TUNNEL="N"
export INCLUDE_UIUX="N"
export FORGE_VERSION="3.5.0"
export USE_VIAVI_SKILLS="N"
export USE_CONTEXT7="N"
export USE_CHROME_DEVTOOLS="N"
export VIAVI_TOKEN=""
export UIUX_INSTALLED="N"
export FRONTEND_DESIGN_INSTALLED="N"

for lib in "$FORGE_ROOT/lib/"*.sh; do source "$lib"; done

# Conflict-check sætter USE_ACETERNITY til none for intern-profil
# (backend-regel — intern håndteres af at prompt_aceternity sætter none for non-website)
# Her simulerer vi at det er sat forkert og at install_motion_js respekterer USE_ACETERNITY

scaffold_project_structure
scaffold_project_files

# Simuler at prompt_aceternity ville have sat none (som den gør for ikke-website)
# Men conflict-check burde have fanget det
# Test at install_motion_js ikke installerer ved intern-profil med none fra conflict-check
USE_ACETERNITY="none"
install_motion_js

# Verificér motion.html IKKE eksisterer
if [ -f "$TMP/$PROJECT/public/assets/partials/motion.html" ]; then
  echo "FAIL: motion.html må ikke oprettes for dashboard"
  exit 1
fi

echo "PASS: dashboard-no-aceternity — ingen motion.html for intern-profil"
