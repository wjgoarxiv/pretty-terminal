#!/usr/bin/env bash
# Install zsh, Oh My Zsh, and Powerlevel10k

install_zsh_setup() {
  local os pkg_mgr
  os="$(detect_os)"
  pkg_mgr="$(detect_pkg_mgr)"

  # --- Install zsh if missing (Linux only, macOS ships with it) ---
  if ! command_exists zsh; then
    info "Installing zsh..."
    case "$pkg_mgr" in
      apt)    sudo apt-get install -y zsh ;;
      dnf)    sudo dnf install -y zsh ;;
      pacman) sudo pacman -S --noconfirm zsh ;;
      *)
        error "Cannot install zsh automatically. Install it manually."
        return 1
        ;;
    esac
    success "zsh installed"
  else
    success "zsh is already installed"
  fi

  # --- Install Oh My Zsh ---
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    success "Oh My Zsh is already installed"
  else
    info "Installing Oh My Zsh..."
    local omz_installer
    omz_installer="$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || {
      error "Failed to download Oh My Zsh installer"
      return 1
    }
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$omz_installer"
    success "Oh My Zsh installed"
  fi

  # --- Install Powerlevel10k ---
  local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  local p10k_dir="$zsh_custom/themes/powerlevel10k"

  if [[ -d "$p10k_dir" ]]; then
    success "Powerlevel10k is already installed"
  else
    info "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
    success "Powerlevel10k installed"
  fi

  # --- Set zsh as default shell ---
  local current_shell
  current_shell="$(basename "$SHELL")"
  if [[ "$current_shell" != "zsh" ]]; then
    info "Setting zsh as default shell..."
    local zsh_path
    zsh_path="$(command -v zsh)"
    # Ensure zsh is in /etc/shells
    if ! grep -qx "$zsh_path" /etc/shells 2>/dev/null; then
      echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi
    chsh -s "$zsh_path" || {
      warn "chsh failed — you may need to set zsh as your default shell manually: chsh -s $zsh_path"
    }
    success "Default shell set to zsh"
  else
    success "zsh is already the default shell"
  fi
}
