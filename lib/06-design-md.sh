#!/bin/bash
# lib/06-design-md.sh — DESIGN.md kilde-valg og awesome-design-md integration

DESIGN_CACHE="$HOME/.local/share/forge/awesome-design-md"

RECOMMENDED_TEMPLATES=(
  "linear.app:Linear — ultra-minimal, lilla accent"
  "stripe:Stripe — lilla gradienter, weight-300 elegance"
  "notion:Notion — varm minimalisme, serif overskrifter"
  "vercel:Vercel — sort/hvid præcision, Geist font"
  "apple:Apple — premium hvidt rum, SF Pro"
  "cursor:Cursor — sleek mørk, gradient accents"
  "supabase:Supabase — dark emerald, code-first"
  "sanity:Sanity — red accent, content-first"
  "sentry:Sentry — dark dashboard, pink-purple"
  "figma:Figma — vibrant multi-color, playful"
)

ensure_design_templates() {
  if [ ! -d "$DESIGN_CACHE" ]; then
    start_spinner "Henter design-templates første gang..."
    mkdir -p "$(dirname "$DESIGN_CACHE")"
    if git clone --depth 1 --quiet https://github.com/VoltAgent/awesome-design-md "$DESIGN_CACHE" 2>/dev/null; then
      stop_spinner "Design-templates hentet"
    else
      stop_spinner_err "Kunne ikke hente design-templates — bruger standard Apple"
      DESIGN_CACHE=""
      return 1
    fi
  elif [ -n "$(find "$DESIGN_CACHE" -maxdepth 0 -mtime +7 2>/dev/null)" ]; then
    start_spinner "Opdaterer design-templates..."
    (cd "$DESIGN_CACHE" && git pull --quiet --depth 1) 2>/dev/null
    stop_spinner "Design-templates opdateret"
  fi
  return 0
}

prompt_design_source() {
  # Springes over for backend-profil (håndteres i conflict-check)
  [ "$PROJECT_PROFILE" = "backend" ] && DESIGN_SOURCE="skip" && export DESIGN_SOURCE && return

  # Springes over i Hurtigt mode — brug default
  if [ "$FORGE_MODE" = "fast" ]; then
    DESIGN_SOURCE="${DEFAULT_DESIGN_SOURCE:-viavi-design-system}"
    DESIGN_TEMPLATE="${DEFAULT_TEMPLATE:-}"
    export DESIGN_SOURCE DESIGN_TEMPLATE
    return
  fi

  echo ""
  echo "  ${BOLD}DESIGN.md kilde:${RESET}"
  echo "    1) ui-ux-pro-max skill         ${DIM}(skill ejer DESIGN.md)${RESET}"
  echo "    2) awesome-design-md template  ${DIM}(31 valg, anbefalet 10 øverst)${RESET}"
  echo "    3) Stitch (Google AI)          ${DIM}(AI-genereret, kræver gcloud)${RESET}"
  echo "    4) Skip — ingen DESIGN.md"
  echo ""
  printf "  Valg [$([ "$DEFAULT_DESIGN_SOURCE" = "viavi-design-system" ] && echo "1" || echo "2")]: "
  read DS_CHOICE
  DS_CHOICE="${DS_CHOICE:-$([ "$DEFAULT_DESIGN_SOURCE" = "viavi-design-system" ] && echo "1" || echo "2")}"

  case "$DS_CHOICE" in
    1)
      DESIGN_SOURCE="viavi-design-system"
      INCLUDE_UIUX="Y"
      export INCLUDE_UIUX
      ;;
    3)
      check_stitch_dependencies
      if [ "$STITCH_AVAILABLE" = "Y" ]; then
        DESIGN_SOURCE="stitch"
      else
        show_stitch_fallback
      fi
      ;;
    4)
      DESIGN_SOURCE="skip"
      ;;
    2|*)
      DESIGN_SOURCE="awesome-design-md"
      prompt_design_template
      ;;
  esac
  export DESIGN_SOURCE
}

prompt_design_template() {
  ensure_design_templates

  echo ""
  echo "  ${BOLD}Vælg design template:${RESET}"
  local i=1
  for entry in "${RECOMMENDED_TEMPLATES[@]}"; do
    local id="${entry%%:*}"
    local label="${entry#*:}"
    printf "   %2d) %s\n" "$i" "$label"
    ((i++))
  done
  echo "    a) Vis alle templates"
  echo "    s) Skip"
  echo ""
  printf "  Valg [1]: "
  read TMP_CHOICE
  TMP_CHOICE="${TMP_CHOICE:-1}"

  if [ "$TMP_CHOICE" = "s" ]; then
    DESIGN_SOURCE="skip"
    export DESIGN_SOURCE
    return
  fi

  if [ "$TMP_CHOICE" = "a" ] && [ -d "$DESIGN_CACHE/design-md" ]; then
    echo ""
    echo "  Alle tilgængelige templates:"
    ls "$DESIGN_CACHE/design-md/" | nl -w4 -s ') '
    echo ""
    printf "  Skriv template-navn: "
    read DESIGN_TEMPLATE
  elif [[ "$TMP_CHOICE" =~ ^[0-9]+$ ]] && [ "$TMP_CHOICE" -ge 1 ] && [ "$TMP_CHOICE" -le ${#RECOMMENDED_TEMPLATES[@]} ]; then
    local entry="${RECOMMENDED_TEMPLATES[$((TMP_CHOICE-1))]}"
    DESIGN_TEMPLATE="${entry%%:*}"
  else
    DESIGN_TEMPLATE="${DEFAULT_TEMPLATE:-linear.app}"
  fi
  export DESIGN_TEMPLATE
}

install_design_md() {
  case "$DESIGN_SOURCE" in
    skip|"")
      return ;;
    viavi-design-system)
      # ui-ux-pro-max skill styrer DESIGN.md — ingen fil oprettes
      return ;;
    awesome-design-md)
      if [ -d "$DESIGN_CACHE/design-md/$DESIGN_TEMPLATE" ]; then
        start_spinner "Installerer $DESIGN_TEMPLATE DESIGN.md..."
        cp "$DESIGN_CACHE/design-md/$DESIGN_TEMPLATE/DESIGN.md" "$PROJECT/DESIGN.md" 2>/dev/null || true
        mkdir -p "$PROJECT/public/design-preview"
        cp "$DESIGN_CACHE/design-md/$DESIGN_TEMPLATE/preview.html" "$PROJECT/public/design-preview/" 2>/dev/null || true
        cp "$DESIGN_CACHE/design-md/$DESIGN_TEMPLATE/preview-dark.html" "$PROJECT/public/design-preview/" 2>/dev/null || true
        stop_spinner "DESIGN.md installeret: $DESIGN_TEMPLATE"
      else
        # Fallback: download fra getdesign.md
        start_spinner "Henter $DESIGN_TEMPLATE DESIGN.md..."
        local url="https://getdesign.md/${DESIGN_TEMPLATE}/design-md"
        local tmp
        tmp=$(mktemp)
        if curl -fsSL --connect-timeout 10 "$url" -o "$tmp" 2>/dev/null && [ -s "$tmp" ]; then
          cp "$tmp" "$PROJECT/DESIGN.md"
          stop_spinner "DESIGN.md hentet: $DESIGN_TEMPLATE"
        else
          rm -f "$tmp"
          # Fallback: Apple default
          cp "$FORGE_ROOT/templates/design-md/apple-default.md" "$PROJECT/DESIGN.md"
          stop_spinner_err "Download fejlede — bruger Apple DESIGN.md"
        fi
        rm -f "$tmp"
      fi
      ;;
    stitch)
      start_spinner "Genererer DESIGN.md via Stitch..."
      # Stitch generering — kræver gcloud
      local stitch_out
      stitch_out=$(gcloud alpha ml generate-content \
        --project="$(gcloud config get-value project)" \
        --region=us-central1 \
        --prompt="Generate a comprehensive DESIGN.md for a $PROJECT_TYPE web project" \
        2>/dev/null || echo "")
      if [ -n "$stitch_out" ]; then
        echo "$stitch_out" > "$PROJECT/DESIGN.md"
        stop_spinner "DESIGN.md genereret via Stitch"
      else
        cp "$FORGE_ROOT/templates/design-md/apple-default.md" "$PROJECT/DESIGN.md"
        stop_spinner_err "Stitch fejlede — bruger Apple DESIGN.md"
      fi
      ;;
    *)
      # Brug Apple default som fallback
      cp "$FORGE_ROOT/templates/design-md/apple-default.md" "$PROJECT/DESIGN.md"
      ;;
  esac

  # Append Aceternity-mønstre til DESIGN.md når "full" valgt
  if [ "$USE_ACETERNITY" = "full" ] && [ -f "$PROJECT/DESIGN.md" ]; then
    start_spinner "Tilføjer Aceternity-mønstre..."
    echo "" >> "$PROJECT/DESIGN.md"
    cat "$FORGE_ROOT/templates/partials/aceternity-patterns.md" >> "$PROJECT/DESIGN.md"
    stop_spinner "aceternity-patterns.md tilføjet til DESIGN.md"
  fi
}
