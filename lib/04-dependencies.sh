#!/bin/bash
# lib/04-dependencies.sh — tjek afhængigheder: gcloud, cloudflared, chrome

check_basic_dependencies() {
  local missing=()
  command -v php  &>/dev/null || missing+=("php")
  command -v git  &>/dev/null || missing+=("git")
  if [ ${#missing[@]} -gt 0 ]; then
    echo "Fejl: Manglende afhængigheder: ${missing[*]}"
    echo "Installér dem og prøv igen."
    exit 1
  fi
}

check_cloudflare_dependency() {
  if [ "$USE_TUNNEL" = "Y" ] && ! command -v cloudflared &>/dev/null; then
    echo ""
    echo "  ⚠  cloudflared ikke fundet."
    echo "     Cloudflare Tunnel deaktiveret."
    echo "     Installér: https://developers.cloudflare.com/cloudflared/install"
    USE_TUNNEL="N"
    export USE_TUNNEL
  fi
}

check_stitch_dependencies() {
  local missing=()

  command -v gcloud &>/dev/null || missing+=("gcloud")

  if command -v gcloud &>/dev/null; then
    gcloud auth application-default print-access-token &>/dev/null || missing+=("auth")
    [ -n "$(gcloud config get-value project 2>/dev/null)" ]         || missing+=("project")
    gcloud services list --enabled --filter="name:stitch.googleapis.com" \
      --format="value(name)" 2>/dev/null | grep -q stitch            || missing+=("api")
  fi

  if [ ${#missing[@]} -eq 0 ]; then
    STITCH_AVAILABLE="Y"
  else
    STITCH_AVAILABLE="N"
    STITCH_MISSING="${missing[*]}"
  fi
  export STITCH_AVAILABLE STITCH_MISSING
}

check_chrome_dependency() {
  if command -v google-chrome &>/dev/null || command -v chromium-browser &>/dev/null || command -v chromium &>/dev/null; then
    CHROME_AVAILABLE="Y"
  else
    CHROME_AVAILABLE="N"
  fi
  export CHROME_AVAILABLE
}

show_stitch_fallback() {
  echo ""
  echo "  ⚠  Stitch kræver: ${STITCH_MISSING}"
  echo ""
  echo "  Vælg alternativ:"
  echo "    1) awesome-design-md template (anbefalet)"
  echo "    2) viavi-design-system"
  echo "    3) Setup-guide: sæt gcloud op og kør Forge igen"
  echo ""
  printf "  Valg [1]: "
  read STITCH_FALLBACK
  STITCH_FALLBACK="${STITCH_FALLBACK:-1}"
  case "$STITCH_FALLBACK" in
    2) DESIGN_SOURCE="viavi-design-system" ;;
    3) echo "  Kør: gcloud auth application-default login && gcloud config set project [PROJEKT-ID]"; exit 0 ;;
    *) DESIGN_SOURCE="awesome-design-md" ;;
  esac
  export DESIGN_SOURCE
}
