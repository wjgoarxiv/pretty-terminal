#!/usr/bin/env bash
# Install eza — modern ls replacement

install_eza() {
  info "Checking for eza..."

  if command_exists eza; then
    success "eza is already installed ($(eza --version | head -1))"
    return 0
  fi

  local os pkg_mgr
  os="$(detect_os)"
  pkg_mgr="$(detect_pkg_mgr)"

  info "Installing eza..."

  case "$os" in
    macos)
      if [[ "$pkg_mgr" != "brew" ]]; then
        error "Homebrew is required to install eza on macOS. Install it from https://brew.sh"
        return 1
      fi
      brew install eza
      ;;

    ubuntu)
      info "Adding eza repository..."
      sudo mkdir -p /etc/apt/keyrings
      curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
        | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
      echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
        | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
      sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
      sudo apt-get update -qq
      sudo apt-get install -y eza
      ;;

    fedora)
      sudo dnf install -y eza
      ;;

    arch)
      sudo pacman -S --noconfirm eza
      ;;

    *)
      warn "Unsupported OS for automatic eza install. Install manually: https://eza.rocks"
      return 1
      ;;
  esac

  # Verify
  if command_exists eza; then
    success "eza installed successfully"
  else
    error "eza installation failed"
    return 1
  fi
}
