#!/usr/bin/env bash
set -euo pipefail

# --- Resolve script directory (handle symlinks) ---
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "${BASH_SOURCE[0]}")")" && pwd)"

# --- Source libraries ---
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/install-font.sh"
source "$SCRIPT_DIR/lib/install-eza.sh"
source "$SCRIPT_DIR/lib/install-zsh.sh"
source "$SCRIPT_DIR/lib/apply-config.sh"

# --- Error trap ---
trap 'error "Installation failed at line $LINENO. Run with bash -x install.sh for details."' ERR

# --- Defaults ---
DO_UNINSTALL=false
FONT_ONLY=false
NO_TERMINAL=false
NO_THEME=false
FONT_CHOICE=jetbrains

# --- Parse arguments ---
usage() {
  cat <<EOF
Usage: ./install.sh [OPTIONS]

Options:
  --uninstall      Restore backups and remove pretty-terminal configs
  --font-only      Only install the Nerd Font, skip everything else
  --no-terminal    Skip terminal emulator config (Ghostty/iTerm2)
  --no-theme       Skip Powerlevel10k theme and .p10k.zsh
  --font CHOICE    Font to install: jetbrains (default) or d2coding
  --help           Show this help message

EOF
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --uninstall)   DO_UNINSTALL=true; shift ;;
    --font-only)   FONT_ONLY=true; shift ;;
    --no-terminal) NO_TERMINAL=true; shift ;;
    --no-theme)    NO_THEME=true; shift ;;
    --font)        FONT_CHOICE="${2:-jetbrains}"; shift 2 ;;
    --help|-h)     usage ;;
    *)
      error "Unknown option: $1"
      usage
      ;;
  esac
done

# --- Uninstall mode ---
if [[ "$DO_UNINSTALL" == "true" ]]; then
  printf "\n${BOLD}pretty-terminal uninstaller${RESET}\n\n"
  uninstall
  exit 0
fi

# --- Banner ---
printf "\n${BOLD}✨ pretty-terminal installer${RESET}\n\n"

# --- Step 1: Detect environment ---
info "Step 1/6: Detecting environment..."
OS="$(detect_os)"
PKG_MGR="$(detect_pkg_mgr)"
success "OS: $OS | Package manager: ${PKG_MGR:-none detected}"

if [[ -z "$PKG_MGR" && "$OS" == "macos" ]]; then
  error "Homebrew is required on macOS. Install from https://brew.sh"
  exit 1
fi

# --- Step 2: Install font ---
info "Step 2/6: Font installation..."
install_font "$FONT_CHOICE"

# Stop here if --font-only
if [[ "$FONT_ONLY" == "true" ]]; then
  printf "\n${GREEN}${BOLD}Done!${RESET} Font installed. Restart your terminal to use it.\n\n"
  exit 0
fi

# --- Step 3: Install eza ---
info "Step 3/6: eza installation..."
install_eza

# --- Step 4: Zsh + Oh My Zsh + Powerlevel10k ---
info "Step 4/6: Zsh setup..."
install_zsh_setup

# --- Step 5: Apply configs ---
info "Step 5/6: Applying configurations..."
apply_configs "$SCRIPT_DIR" "$NO_THEME" "$FONT_CHOICE"

# --- Step 6: Terminal config ---
if [[ "$NO_TERMINAL" != "true" ]]; then
  info "Step 6/6: Terminal configuration..."
  apply_terminal_config "$SCRIPT_DIR" "$FONT_CHOICE"
else
  info "Step 6/6: Skipping terminal configuration (--no-terminal)"
fi

# --- Done ---
printf "\n${GREEN}${BOLD}✨ pretty-terminal installed successfully!${RESET}\n\n"
printf "  ${BOLD}Next steps:${RESET}\n"
FONT_DISPLAY_NAME="JetBrainsMono Nerd Font"
if [[ "$FONT_CHOICE" == "d2coding" ]]; then
  FONT_DISPLAY_NAME="D2CodingLigature Nerd Font Mono"
fi
printf "  1. Restart your terminal (or run: exec zsh)\n"
printf "  2. Set your terminal font to ${BOLD}%s${RESET}\n" "$FONT_DISPLAY_NAME"
printf "  3. Enjoy your pretty terminal!\n\n"
