#!/usr/bin/env bash
# Shared utility functions for pretty-terminal installer

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

# --- Logging ---
info() {
  printf "${BLUE}[INFO]${RESET} %s\n" "$1"
}

success() {
  printf "${GREEN}[OK]${RESET} %s\n" "$1"
}

warn() {
  printf "${YELLOW}[WARN]${RESET} %s\n" "$1"
}

error() {
  printf "${RED}[ERROR]${RESET} %s\n" "$1" >&2
}

# --- OS Detection ---
detect_os() {
  local uname_s
  uname_s="$(uname -s)"

  if [[ "$uname_s" == "Darwin" ]]; then
    echo "macos"
    return
  fi

  if [[ "$uname_s" != "Linux" ]]; then
    echo "unknown"
    return
  fi

  # Linux — check distro via /etc/os-release
  if [[ -f /etc/os-release ]]; then
    local id
    id="$(. /etc/os-release && echo "${ID:-}")"
    case "$id" in
      ubuntu|debian|linuxmint|pop) echo "ubuntu" ;;
      fedora|rhel|centos|rocky|alma) echo "fedora" ;;
      arch|manjaro|endeavouros) echo "arch" ;;
      *) echo "linux-unknown" ;;
    esac
  else
    echo "linux-unknown"
  fi
}

# --- Package Manager Detection ---
detect_pkg_mgr() {
  local os
  os="$(detect_os)"

  case "$os" in
    macos)
      if command_exists brew; then
        echo "brew"
      else
        echo ""
      fi
      ;;
    ubuntu)  echo "apt" ;;
    fedora)  echo "dnf" ;;
    arch)    echo "pacman" ;;
    *)       echo "" ;;
  esac
}

# --- Command Check ---
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# --- Backup ---
backup_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    local backup="${file}.bak"
    if [[ -f "$backup" ]]; then
      # Existing .bak — use timestamp to avoid overwrite
      backup="${file}.bak.$(date +%Y%m%d%H%M%S)"
    fi
    cp "$file" "$backup"
    info "Backed up $file -> $backup"
  fi
}
