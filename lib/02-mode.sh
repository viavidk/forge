#!/bin/bash
# lib/02-mode.sh — Hurtigt / Guided / Avanceret mode-valg

prompt_mode() {
  # Respektér flag fra start-forge.sh (--guided / --advanced)
  if [ -n "${FORCE_MODE:-}" ]; then
    FORGE_MODE="$FORCE_MODE"
    export FORGE_MODE
    return
  fi

  echo ""
  echo "  ${BOLD}Vælg mode:${RESET}"
  echo "    ${BOLD}1) Hurtigt${RESET}    — 2 spørgsmål, smart defaults (~10 sek)"
  echo "    2) Guided     — 8 trin, vælg alt vigtigt (~1 min)"
  echo "    3) Avanceret  — alle valg, fuld kontrol (~3 min)"
  echo ""
  printf "  Mode [1]: "
  read MODE_CHOICE
  MODE_CHOICE="${MODE_CHOICE:-1}"

  case "$MODE_CHOICE" in
    2) FORGE_MODE="guided" ;;
    3) FORGE_MODE="advanced" ;;
    *)  FORGE_MODE="fast" ;;
  esac

  export FORGE_MODE
}
