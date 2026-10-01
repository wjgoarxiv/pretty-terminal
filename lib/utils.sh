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

# --- Apple Silicon Architecture ---
# True on an Apple Silicon Mac, even when the current shell runs under Rosetta.
is_apple_silicon_host() {
  [[ "$(uname -s)" == "Darwin" && "$(/usr/sbin/sysctl -n hw.optional.arm64 2>/dev/null || true)" == "1" ]]
}

# True when the file is a Mach-O binary without an arm64 slice.
is_x86_only_binary() {
  local info
  info="$(file -L -b "$1" 2>/dev/null || true)"
  [[ "$info" == *x86_64* && "$info" != *arm64* ]]
}

# Re-run the installer natively when an Apple Silicon Mac started it under Rosetta,
# so everything it installs is arm64 instead of x86_64.
ensure_native_arch() {
  local script_path="$1"
  shift

  is_apple_silicon_host || return 0
  [[ "$(uname -m)" != "arm64" ]] || return 0

  if [[ -n "${PRETTY_TERMINAL_NATIVE_REEXEC:-}" ]]; then
    error "Still running as $(uname -m) after re-exec. Open a native arm64 terminal and retry."
    exit 1
  fi

  warn "Rosetta (x86_64) shell detected on Apple Silicon. Re-running as arm64..."
  PRETTY_TERMINAL_NATIVE_REEXEC=1 exec arch -arm64 /bin/bash "$script_path" "$@"
}

# On Apple Silicon, put the native Homebrew (/opt/homebrew) ahead of an Intel one
# (/usr/local) so `brew install` yields arm64 binaries.
use_native_homebrew() {
  is_apple_silicon_host || return 0

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    error "Only Intel Homebrew (/usr/local) found; it would install x86_64 binaries on Apple Silicon."
    error "Install native Homebrew (/opt/homebrew) from https://brew.sh and retry."
    return 1
  fi
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
