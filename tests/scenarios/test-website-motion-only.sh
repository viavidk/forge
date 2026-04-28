#!/bin/bash
# Test: website med kun Motion JS — motion.html men INGEN Aceternity-patterns
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

cd "$TMP"

export PROJECT="testprojekt"
export PROJECT_PROFILE="website"
export USE_ACETERNITY="motion"
export USE_TAILWIND="Y"
export DESIGN_SOURCE="skip"
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

scaffold_project_structure
scaffold_project_files
install_motion_js

# Verificér motion.html eksisterer
if [ ! -f "$TMP/$PROJECT/public/assets/partials/motion.html" ]; then
  echo "FAIL: motion.html mangler ved motion-only"
  exit 1
fi

# Ingen DESIGN.md (skip) — så ingen aceternity-patterns tilføjet
if [ -f "$TMP/$PROJECT/DESIGN.md" ]; then
  if grep -q "Animation Patterns" "$TMP/$PROJECT/DESIGN.md"; then
    echo "FAIL: Aceternity-patterns må ikke tilføjes ved motion-only"
    exit 1
  fi
fi

echo "PASS: website-motion-only — motion.html OK, ingen aceternity-patterns"
