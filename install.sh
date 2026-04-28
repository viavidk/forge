#!/bin/bash
# ViaVi Forge — installer
# Brug: curl -fsSL https://raw.githubusercontent.com/viavidk/forge/main/install.sh | bash
set -e

INSTALL_DIR="$HOME/.local/share/forge"
BIN_DIR="$HOME/.local/bin"
REPO="https://github.com/viavidk/forge"

# Farver
BOLD="\033[1m"
RESET="\033[0m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"

ok()   { echo -e "  ${GREEN}✓${RESET} $*"; }
warn() { echo -e "  ${YELLOW}!${RESET} $*"; }
err()  { echo -e "  ${RED}✗${RESET} $*"; exit 1; }

echo ""
echo -e "  ${BOLD}ViaVi Forge${RESET} — installerer..."
echo ""

# Tjek dependencies
for cmd in git bash curl; do
  command -v "$cmd" &>/dev/null || err "Mangler: $cmd — installer det og prøv igen"
done

# Bash version >= 4
bash_major="${BASH_VERSINFO[0]}"
[ "$bash_major" -ge 4 ] || err "Kræver bash 4+. Din version: $BASH_VERSION"

# Klon eller opdater
if [ -d "$INSTALL_DIR/.git" ]; then
  echo "  Opdaterer eksisterende installation..."
  (cd "$INSTALL_DIR" && git pull --quiet)
  ok "Opdateret til seneste version"
else
  echo "  Henter Forge fra GitHub..."
  git clone --quiet "$REPO" "$INSTALL_DIR"
  ok "Forge hentet"
fi

# Symlink til ~/.local/bin/forge
mkdir -p "$BIN_DIR"
ln -sf "$INSTALL_DIR/start-forge.sh" "$BIN_DIR/forge"
chmod +x "$INSTALL_DIR/start-forge.sh"
ok "Symlink oprettet: $BIN_DIR/forge"

# Tjek PATH
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo ""
  warn "Tilføj denne linje til din ~/.bashrc eller ~/.zshrc:"
  echo ""
  echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
  echo ""
  warn "Kør derefter: source ~/.bashrc (eller åbn ny terminal)"
fi

echo ""
ok "Forge er installeret"
echo ""
echo -e "  Kør:  ${BOLD}forge${RESET}"
echo -e "  Hjælp: ${BOLD}forge --help${RESET}"
echo -e "  Opdatér: ${BOLD}forge update${RESET}"
echo ""
