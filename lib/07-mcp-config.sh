#!/bin/bash
# lib/07-mcp-config.sh — .mcp.json generering + token-håndtering

KEYS_FILE="$HOME/.config/forge/keys.env"

load_viavi_token() {
  [ -f "$KEYS_FILE" ] && grep -oP 'VIAVI_TOKEN=\K[^\s]+' "$KEYS_FILE" 2>/dev/null || echo ""
}

prompt_mcps() {
  # Hurtigt mode: brug defaults
  if [ "$FORGE_MODE" = "fast" ]; then
    USE_VIAVI_SKILLS="${USE_VIAVI_SKILLS:-Y}"
    USE_CONTEXT7="${USE_CONTEXT7:-Y}"
    USE_CHROME_DEVTOOLS="${USE_CHROME_DEVTOOLS:-Y}"
    [ "$PROJECT_PROFILE" = "backend" ] && USE_VIAVI_SKILLS="N" && USE_CHROME_DEVTOOLS="N"
    export USE_VIAVI_SKILLS USE_CONTEXT7 USE_CHROME_DEVTOOLS
    return
  fi

  echo ""
  echo "  ${BOLD}MCP-servere:${RESET}"

  # ViaVi Skills
  printf "  Inkludér ViaVi Skills MCP? [Y/n] "
  read vs; vs="${vs:-Y}"
  USE_VIAVI_SKILLS="$([[ "${vs,,}" == "n" ]] && echo "N" || echo "Y")"

  # Context7
  printf "  Inkludér Context7 (dokumentation i realtid)? [Y/n] "
  read c7; c7="${c7:-Y}"
  USE_CONTEXT7="$([[ "${c7,,}" == "n" ]] && echo "N" || echo "Y")"

  # Chrome DevTools
  printf "  Inkludér Chrome DevTools MCP? [Y/n] "
  read ch; ch="${ch:-Y}"
  USE_CHROME_DEVTOOLS="$([[ "${ch,,}" == "n" ]] && echo "N" || echo "Y")"

  export USE_VIAVI_SKILLS USE_CONTEXT7 USE_CHROME_DEVTOOLS
}

prompt_viavi_token() {
  [ "$USE_VIAVI_SKILLS" != "Y" ] && return

  local existing
  existing=$(load_viavi_token)

  if [ -n "$existing" ]; then
    echo "  ${DIM}ViaVi token fundet i $KEYS_FILE${RESET}"
    VIAVI_TOKEN="$existing"
    export VIAVI_TOKEN
    return
  fi

  echo ""
  echo "  ${BOLD}ViaVi Skills token:${RESET}"
  echo "    1) Jeg har en token klar"
  echo "    2) Jeg har ingen token endnu"
  echo "    3) Nej, ikke i dette projekt"
  printf "  Valg [1]: "
  read tok_choice
  tok_choice="${tok_choice:-1}"

  case "$tok_choice" in
    2)
      echo ""
      echo "  ViaVi Skills er et gratis bibliotek af AI-skills."
      echo "  Opret konto og hent token her:"
      echo ""
      echo "    https://app.viavi.dk/skills"
      echo ""
      echo "    → Min profil → API-nøgler → Opret ny"
      echo ""
      echo "  Kør derefter forge igen og vælg \"Jeg har en token\"."
      echo ""
      printf "  [Tryk Enter for at fortsætte uden ViaVi Skills] "
      read _dummy
      VIAVI_TOKEN=""
      ;;
    3)
      USE_VIAVI_SKILLS="N"
      VIAVI_TOKEN=""
      ;;
    1|*)
      printf "  Indsæt token: "
      read -s VIAVI_TOKEN
      echo ""
      if [ -n "$VIAVI_TOKEN" ]; then
        printf "  Gem token i %s? [Y/n] " "$KEYS_FILE"
        read save_tok; save_tok="${save_tok:-Y}"
        if [[ "${save_tok,,}" != "n" ]]; then
          mkdir -p "$(dirname "$KEYS_FILE")"
          # Opdater eller tilføj
          if grep -q "VIAVI_TOKEN=" "$KEYS_FILE" 2>/dev/null; then
            sed -i "s|VIAVI_TOKEN=.*|VIAVI_TOKEN=${VIAVI_TOKEN}|" "$KEYS_FILE"
          else
            echo "VIAVI_TOKEN=${VIAVI_TOKEN}" >> "$KEYS_FILE"
          fi
          chmod 600 "$KEYS_FILE"
          echo "  Token gemt"
        fi
      fi
      ;;
  esac
  export VIAVI_TOKEN USE_VIAVI_SKILLS
}

generate_mcp_config() {
  local has_servers=false
  local servers="{}"

  # Byg JSON
  local json='{'
  local first=true

  if [ "$USE_VIAVI_SKILLS" = "Y" ]; then
    [ "$first" = "true" ] || json+=","
    json+='"viavi-skills":{"url":"https://app.viavi.dk/skills/mcp","transport":"http","headers":{"Authorization":"Bearer ${VIAVI_TOKEN}"}}'
    first=false
    has_servers=true
  fi

  if [ "$USE_CONTEXT7" = "Y" ]; then
    [ "$first" = "true" ] || json+=","
    json+='"context7":{"command":"npx","args":["-y","@upstash/context7-mcp@latest"]}'
    first=false
    has_servers=true
  fi

  if [ "$USE_CHROME_DEVTOOLS" = "Y" ]; then
    [ "$first" = "true" ] || json+=","
    json+='"chrome-devtools":{"command":"npx","args":["-y","chrome-devtools-mcp@latest"]}'
    first=false
    has_servers=true
  fi

  json+='}'

  if [ "$has_servers" = "true" ]; then
    # .mcp.json med token interpoleret
    cat > "$PROJECT/.mcp.json" << MCPEOF
{
  "mcpServers": ${json}
}
MCPEOF

    # .mcp.json.example uden token
    local json_example="${json/\$\{VIAVI_TOKEN\}/YOUR_VIAVI_TOKEN_HERE}"
    cat > "$PROJECT/.mcp.json.example" << MCPEXEOF
{
  "mcpServers": ${json_example}
}
MCPEXEOF

    # Tilføj .mcp.json til .gitignore (ikke .example)
    if ! grep -q "^\.mcp\.json$" "$PROJECT/.gitignore" 2>/dev/null; then
      echo ".mcp.json" >> "$PROJECT/.gitignore"
    fi

    echo "  ✓  .mcp.json genereret"
  fi
}
