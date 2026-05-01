#!/bin/bash
# lib/15-superpowers.sh — Superpowers plugin integration (v3.6.0)
#
# Superpowers er et Claude Code plugin (Jesse Vincent, MIT) der tilføjer 14
# skills som tvinger Claude igennem Clarify → Design → Plan → Code → Verify.
# Vi installerer kun konfigurationen — selve plugin'et auto-installeres når
# brugeren åbner projektet med `claude`.

prompt_agentic_discipline() {
  # v3.6.5: Fuld pakke altid — orkestreringen er usynlig for brugeren.
  # SUPERPOWERS_DEFAULT / AGENTS_DEFAULT kan overstyres fra tests og --advanced.
  INSTALL_SUPERPOWERS="${SUPERPOWERS_DEFAULT:-Y}"
  INSTALL_AGENTS="${AGENTS_DEFAULT:-recommended}"
  export INSTALL_SUPERPOWERS INSTALL_AGENTS
}

# Bash-versions-tjek. Plugin selv kører via Claude Code, men prompt-flow'en i
# Superpowers bruger associative arrays.
check_superpowers_compatibility() {
  if [ "${INSTALL_SUPERPOWERS:-N}" != "Y" ]; then
    return 0
  fi
  if [ "${BASH_VERSINFO[0]:-3}" -lt 4 ]; then
    echo "  ⚠  Superpowers anbefaler bash 4+. Din: $BASH_VERSION"
    echo "     Plugin kører stadig (Claude Code har egen bash), men advarsel logges."
  fi
}

install_superpowers() {
  if [ "${INSTALL_SUPERPOWERS:-N}" != "Y" ]; then
    return 0
  fi

  start_spinner "Konfigurerer Superpowers plugin..."

  mkdir -p "$PROJECT/.claude"
  local settings="$PROJECT/.claude/settings.json"
  local marketplace_url="https://github.com/obra/superpowers-marketplace"

  # Brug python3 til at merge ind i eksisterende settings.json (eller skabe ny).
  # Korrekt Claude Code-format: enabledPlugins[] + extraKnownMarketplaces[].
  python3 - "$settings" "$marketplace_url" <<'PYEOF'
import json, os, sys

path = sys.argv[1]
url  = sys.argv[2]

if os.path.exists(path):
    try:
        with open(path) as f:
            data = json.load(f)
    except Exception:
        data = {}
else:
    data = {}

plugins = data.setdefault("enabledPlugins", [])
if "superpowers" not in plugins:
    plugins.append("superpowers")

mps = data.setdefault("extraKnownMarketplaces", [])
if not any(m.get("url") == url for m in mps if isinstance(m, dict)):
    mps.append({"url": url})

with open(path, "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
PYEOF

  stop_spinner "Superpowers konfigureret i .claude/settings.json"
}
