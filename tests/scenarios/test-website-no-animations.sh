#!/bin/bash
# Test: website uden animationer — hverken motion.html eller Aceternity
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

cd "$TMP"

export PROJECT="testprojekt"
export PROJECT_PROFILE="website"
export USE_ACETERNITY="none"
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

# Verificér motion.html IKKE eksisterer
if [ -f "$TMP/$PROJECT/public/assets/partials/motion.html" ]; then
  echo "FAIL: motion.html må ikke oprettes ved none"
  exit 1
fi

echo "PASS: website-no-animations — hverken motion.html eller aceternity"
