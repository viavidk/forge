#!/bin/bash
# lib/01-prompts.sh — alle interactive prompts

prompt_project_name() {
  read -p "Projektnavn: " PROJECT
  if [ -z "$PROJECT" ]; then
    echo "Fejl: Projektnavn må ikke være tomt."
    exit 1
  fi
  if [[ ! "$PROJECT" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Fejl: Projektnavn må kun indeholde bogstaver, tal, - og _ (ingen mellemrum)."
    exit 1
  fi
  if [ -d "$PROJECT" ]; then
    echo ""
    printf "  ${BOLD}Mappen '$PROJECT' eksisterer allerede.${RESET}\n"
    printf "  Opgradér Forge-konfiguration? ${DIM}(CLAUDE.md, rules, agents — din kode røres ikke)${RESET} [j/N] "
    read UPGRADE_CONFIRM
    UPGRADE_CONFIRM="${UPGRADE_CONFIRM:-N}"
    if [[ "${UPGRADE_CONFIRM,,}" != "j" ]]; then
      echo "  Annulleret."
      exit 0
    fi
    UPGRADE=true
    # I upgrade-mode: læs eksisterende config hvis mulig
    load_existing_config
  else
    UPGRADE=false
  fi
  export PROJECT UPGRADE
}

load_existing_config() {
  # Forsøg at læse eksisterende opsætning fra PROJECT/.env eller start.sh
  if [ -f "$PROJECT/start.sh" ]; then
    EXISTING_PORT=$(grep -oP 'PORT=\K[0-9]+' "$PROJECT/start.sh" 2>/dev/null | head -1 || echo "")
    [ -n "$EXISTING_PORT" ] && PORT="$EXISTING_PORT" && export PORT
  fi
  export UPGRADE_HAS_EXISTING_CONFIG=true
}

prompt_port() {
  if [ "$UPGRADE" = "false" ]; then
    local default_port="${PORT:-8080}"
    read -p "Lokal port [${default_port}]: " PORT_INPUT
    PORT="${PORT_INPUT:-$default_port}"
    if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1 ] || [ "$PORT" -gt 65535 ]; then
      echo "Fejl: Port skal være et tal mellem 1 og 65535."
      exit 1
    fi
    export PORT
  fi
}

prompt_routing() {
  if [ "$UPGRADE" = "false" ]; then
    printf "  Apache routing (.htaccess + router.php)? [Y/n]: "
    read USE_ROUTER
    USE_ROUTER="${USE_ROUTER:-Y}"
    USE_ROUTER="${USE_ROUTER^^}"

    if [ "$USE_ROUTER" = "Y" ]; then
      echo ""
      echo "  Hvor ligger projektet på serveren?"
      echo "    Eksempel: https://app.viavi.dk/kursus → skriv /kursus"
      echo "    Eksempel: https://app.viavi.dk/       → lad stå tom"
      echo ""
      read -p "  URL-sti på server (fx /kursus): " SUBPATH
      SUBPATH="${SUBPATH:-/}"
      if [[ ! "$SUBPATH" =~ ^[a-zA-Z0-9/_-]*$ ]]; then
        echo "Fejl: URL-sti må kun indeholde bogstaver, tal, / _ og -"
        exit 1
      fi
      SUBPATH="/${SUBPATH#/}"
      SUBPATH="${SUBPATH%/}"
      REWRITEBASE="${SUBPATH}/public/"
      if [ "$SUBPATH" = "/" ]; then
        REWRITEBASE="/public/"
      fi
    fi
    export USE_ROUTER SUBPATH REWRITEBASE
  fi
}

prompt_cloudflare() {
  if [ "$UPGRADE" = "false" ]; then
    local default="${DEFAULT_TUNNEL:-N}"
    printf "  Cloudflare Tunnel (ekstern URL, kræver cloudflared)? [$([ "$default" = "Y" ] && echo "Y/n" || echo "y/N")]: "
    read USE_TUNNEL
    USE_TUNNEL="${USE_TUNNEL:-$default}"
    if [[ "${USE_TUNNEL,,}" == "n" ]]; then
      USE_TUNNEL="N"
    else
      USE_TUNNEL="Y"
    fi
    export USE_TUNNEL
  fi
}

prompt_uiux() {
  local default="${DEFAULT_UIUX:-Y}"
  printf "  ${BOLD}Inkludér ui-ux-pro-max design skill?${RESET} [$([ "$default" = "Y" ] && echo "Y/n" || echo "y/N")] "
  read INCLUDE_UIUX
  INCLUDE_UIUX="${INCLUDE_UIUX:-$default}"
  if [[ "${INCLUDE_UIUX,,}" == "n" ]]; then
    INCLUDE_UIUX="N"
  else
    INCLUDE_UIUX="Y"
  fi
  export INCLUDE_UIUX
}

prompt_tailwind() {
  local default="${DEFAULT_TAILWIND:-Y}"
  printf "  ${BOLD}Inkludér Tailwind CSS?${RESET} ${DIM}(Play CDN — ingen build)${RESET} [$([ "$default" = "Y" ] && echo "Y/n" || echo "y/N")] "
  read USE_TAILWIND
  USE_TAILWIND="${USE_TAILWIND:-$default}"
  if [[ "${USE_TAILWIND,,}" == "n" ]]; then
    USE_TAILWIND="N"
  else
    USE_TAILWIND="Y"
  fi
  export USE_TAILWIND
}

prompt_aceternity() {
  # Kun vist for website-profil
  if [ "$PROJECT_PROFILE" = "website" ]; then
    local default="${DEFAULT_ACETERNITY:-Y}"
    printf "  ${BOLD}Inkludér Aceternity UI + Motion JS?${RESET} ${DIM}(animerede komponenter via CDN)${RESET} [$([ "$default" = "Y" ] && echo "Y/n" || echo "y/N")] "
    read USE_ACETERNITY
    USE_ACETERNITY="${USE_ACETERNITY:-$default}"
    if [[ "${USE_ACETERNITY,,}" == "n" ]]; then
      USE_ACETERNITY="N"
    else
      USE_ACETERNITY="Y"
    fi
  else
    USE_ACETERNITY="N"
  fi
  export USE_ACETERNITY
}
