#!/bin/bash
# lib/05-conflict-check.sh — forhindrer modarbejdende valg

validate_no_conflicts() {
  local errors=()

  # Regel 1: kun én DESIGN.md-kilde
  if [ "$INCLUDE_UIUX" = "Y" ] && [ "$DESIGN_SOURCE" = "awesome-design-md" ]; then
    errors+=("Konflikt: ui-ux-pro-max og awesome-design-md kan ikke bruges sammen. Vælg én.")
  fi
  if [ "$INCLUDE_UIUX" = "Y" ] && [ "$DESIGN_SOURCE" = "stitch" ]; then
    errors+=("Konflikt: ui-ux-pro-max og Stitch kan ikke bruges sammen. Vælg én.")
  fi

  # Regel 2: backend + Aceternity giver ingen mening
  if [ "$PROJECT_PROFILE" = "backend" ] && [ "$USE_ACETERNITY" != "none" ]; then
    echo "  ⚠  Aceternity deaktiveret (ikke relevant for backend-profil)"
    USE_ACETERNITY="none"
    export USE_ACETERNITY
  fi

  # Regel 3: backend + DESIGN.md
  if [ "$PROJECT_PROFILE" = "backend" ] && [ "$DESIGN_SOURCE" != "skip" ] && [ "$DESIGN_SOURCE" != "" ]; then
    echo "  ⚠  DESIGN.md deaktiveret (ikke relevant for backend-profil)"
    DESIGN_SOURCE="skip"
    export DESIGN_SOURCE
  fi

  # Regel 4: backend + Tailwind
  if [ "$PROJECT_PROFILE" = "backend" ] && [ "$USE_TAILWIND" = "Y" ]; then
    echo "  ⚠  Tailwind deaktiveret (backend-profil har intet UI)"
    USE_TAILWIND="N"
    export USE_TAILWIND
  fi

  # Regel 5: bash-version + Superpowers (kun warning, ikke fejl)
  check_superpowers_compatibility 2>/dev/null || true

  if [ ${#errors[@]} -gt 0 ]; then
    echo ""
    echo "  ✗ Konflikter fundet:"
    for err in "${errors[@]}"; do
      echo "    - $err"
    done
    echo ""
    echo "Kør Forge igen og vælg kompatible indstillinger."
    exit 1
  fi
}
