#!/bin/bash
# Test: website med Aceternity full — verificerer DESIGN.md + motion.html
set -e

FORGE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT

cd "$TMP"

# Simulér scaffold med USE_ACETERNITY=full
export PROJECT="testprojekt"
export PROJECT_PROFILE="website"
export PROJECT_TYPE="website"
export FORGE_MODE="fast"
export USE_ACETERNITY="full"
export USE_TAILWIND="Y"
export DESIGN_SOURCE="awesome-design-md"
export DESIGN_TEMPLATE="linear.app"
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
  echo "FAIL: motion.html mangler"
  exit 1
fi

# Verificér indhold af motion.html
if ! grep -q "motion@latest" "$TMP/$PROJECT/public/assets/partials/motion.html"; then
  echo "FAIL: motion.html mangler CDN-link"
  exit 1
fi

# Simulér install_design_md med lokal fallback
cp "$FORGE_ROOT/templates/design-md/apple-default.md" "$TMP/$PROJECT/DESIGN.md"
# Append aceternity-patterns manuelt (som install_design_md gør)
echo "" >> "$TMP/$PROJECT/DESIGN.md"
cat "$FORGE_ROOT/templates/partials/aceternity-patterns.md" >> "$TMP/$PROJECT/DESIGN.md"

# Verificér DESIGN.md har Aceternity-sektion
if ! grep -q "Animation Patterns" "$TMP/$PROJECT/DESIGN.md"; then
  echo "FAIL: DESIGN.md mangler Aceternity-sektion"
  exit 1
fi

echo "PASS: website-aceternity-full — motion.html + aceternity-patterns i DESIGN.md"
