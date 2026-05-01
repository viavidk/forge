#!/bin/bash
# lib/_common.sh — farver, spinner, print helpers

BOLD=$(tput bold 2>/dev/null || printf '')
DIM=$(tput dim 2>/dev/null || printf '')
RESET=$(tput sgr0 2>/dev/null || printf '')
GREEN=$(tput setaf 2 2>/dev/null || printf '')
YELLOW=$(tput setaf 3 2>/dev/null || printf '')
CYAN=$(tput setaf 6 2>/dev/null || printf '')
RED=$(tput setaf 1 2>/dev/null || printf '')

FORGE_VERSION="${FORGE_VERSION:-3.6.1}"

_spinner_pid=""

start_spinner() {
  local msg="$1"
  if [ -n "$_spinner_pid" ]; then
    kill "$_spinner_pid" 2>/dev/null
    wait "$_spinner_pid" 2>/dev/null || true
    _spinner_pid=""
  fi
  (
    local chars='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while true; do
      printf "\r  ${chars:$i:1}  %s" "$msg"
      i=$(( (i + 1) % ${#chars} ))
      sleep 0.08
    done
  ) &
  _spinner_pid=$!
}

stop_spinner() {
  local msg="$1"
  if [ -n "$_spinner_pid" ]; then
    kill "$_spinner_pid" 2>/dev/null
    wait "$_spinner_pid" 2>/dev/null || true
    _spinner_pid=""
  fi
  printf "\r  ✓  %s\n" "$msg"
}

stop_spinner_err() {
  local msg="$1"
  if [ -n "$_spinner_pid" ]; then
    kill "$_spinner_pid" 2>/dev/null
    wait "$_spinner_pid" 2>/dev/null || true
    _spinner_pid=""
  fi
  printf "\r  ⚠  %s\n" "$msg"
}

kill_spinner() {
  if [ -n "$_spinner_pid" ]; then
    kill "$_spinner_pid" 2>/dev/null
    wait "$_spinner_pid" 2>/dev/null || true
    _spinner_pid=""
    printf "\r                                                           \r"
  fi
}

print_header() {
  echo ""
  echo "${BOLD}ViaVi Forge v${FORGE_VERSION}${RESET} · viavi.dk"
  echo "────────────────────────────────"
  echo ""
}

print_section() {
  echo ""
  echo "${DIM}$1${RESET}"
}

confirm_yn() {
  local prompt="$1"
  local default="${2:-Y}"
  local answer
  printf "  %s [%s] " "$prompt" "$([ "$default" = "Y" ] && echo "Y/n" || echo "y/N")"
  read answer
  answer="${answer:-$default}"
  [[ "${answer,,}" == "y" ]] && return 0 || return 1
}
