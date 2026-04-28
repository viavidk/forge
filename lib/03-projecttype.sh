#!/bin/bash
# lib/03-projecttype.sh — 5 projekttyper med smart defaults og preferences

PREFS_FILE="$HOME/.config/forge/preferences.json"

load_pref() {
  local type="$1" key="$2"
  [ -f "$PREFS_FILE" ] && python3 -c "
import json, sys
try:
    d = json.load(open('$PREFS_FILE'))
    print(d.get('lastUsed', {}).get('$type', {}).get('$key', ''))
except: pass
" 2>/dev/null || true
}

save_pref() {
  local type="$1"
  mkdir -p "$(dirname "$PREFS_FILE")"
  python3 -c "
import json, os
f = '$PREFS_FILE'
try:
    d = json.load(open(f)) if os.path.exists(f) else {}
except:
    d = {}
d.setdefault('lastUsed', {})['$type'] = {
    'design':    '${DESIGN_SOURCE:-}',
    'template':  '${DESIGN_TEMPLATE:-}',
    'aceternity':'${USE_ACETERNITY:-N}',
    'cloudflare':'${USE_TUNNEL:-N}',
    'mcps':      '${USE_MCPS:-all}',
}
json.dump(d, open(f, 'w'), indent=2)
" 2>/dev/null || true
}

prompt_project_type() {
  echo ""
  echo "  ${BOLD}Hvad bygger du?${RESET}"
  echo "    1) Dashboard / analyse"
  echo "    2) Internt værktøj / admin"
  echo "    3) Website"
  echo "    4) E-commerce"
  echo "    5) API / Backend"
  echo ""
  printf "  Type [1]: "
  read TYPE_CHOICE
  TYPE_CHOICE="${TYPE_CHOICE:-1}"

  case "$TYPE_CHOICE" in
    3) PROJECT_TYPE="website"    ; PROJECT_PROFILE="website"  ;;
    4) PROJECT_TYPE="ecommerce"  ; PROJECT_PROFILE="website"  ;;
    5) PROJECT_TYPE="api"        ; PROJECT_PROFILE="backend"  ;;
    2) PROJECT_TYPE="internal"   ; PROJECT_PROFILE="intern"   ;;
    *) PROJECT_TYPE="dashboard"  ; PROJECT_PROFILE="intern"   ;;
  esac

  # Defaults per profil
  case "$PROJECT_PROFILE" in
    website)
      DEFAULT_DESIGN_SOURCE="awesome-design-md"
      DEFAULT_TEMPLATE=$([ "$PROJECT_TYPE" = "ecommerce" ] && echo "stripe" || echo "linear.app")
      DEFAULT_ACETERNITY="full"
      DEFAULT_TUNNEL="Y"
      DEFAULT_TAILWIND="Y"
      DEFAULT_MCPS="all"
      ;;
    backend)
      DEFAULT_DESIGN_SOURCE="skip"
      DEFAULT_TEMPLATE=""
      DEFAULT_ACETERNITY="none"
      DEFAULT_TUNNEL="N"
      DEFAULT_TAILWIND="N"
      DEFAULT_MCPS="context7-only"
      ;;
    intern|*)
      DEFAULT_DESIGN_SOURCE="viavi-design-system"
      DEFAULT_TEMPLATE=""
      DEFAULT_ACETERNITY="none"
      DEFAULT_TUNNEL="N"
      DEFAULT_TAILWIND="Y"
      DEFAULT_MCPS="all"
      ;;
  esac

  # Overstyr defaults med brugerens forrige valg hvis de eksisterer
  local saved_design saved_tmpl saved_aceternity
  saved_design=$(load_pref "$PROJECT_TYPE" "design")
  saved_tmpl=$(load_pref "$PROJECT_TYPE" "template")
  saved_aceternity=$(load_pref "$PROJECT_TYPE" "aceternity")

  [ -n "$saved_design" ]     && DEFAULT_DESIGN_SOURCE="$saved_design"
  [ -n "$saved_tmpl" ]       && DEFAULT_TEMPLATE="$saved_tmpl"
  [ -n "$saved_aceternity" ] && DEFAULT_ACETERNITY="$saved_aceternity"

  export PROJECT_TYPE PROJECT_PROFILE
  export DEFAULT_DESIGN_SOURCE DEFAULT_TEMPLATE DEFAULT_ACETERNITY
  export DEFAULT_TUNNEL DEFAULT_TAILWIND DEFAULT_MCPS
}
