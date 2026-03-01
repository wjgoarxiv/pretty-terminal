#!/usr/bin/env bash
# Apply pretty-terminal configuration files

apply_configs() {
  local script_dir="$1"
  local no_theme="${2:-false}"

  local zshrc="$HOME/.zshrc"

  # Ensure .zshrc exists
  if [[ ! -f "$zshrc" ]]; then
    warn ".zshrc not found, creating one"
    touch "$zshrc"
  fi

  # --- Copy .p10k.zsh ---
  if [[ "$no_theme" != "true" ]]; then
    if [[ -f "$script_dir/configs/.p10k.zsh" ]]; then
      backup_file "$HOME/.p10k.zsh"
      cp "$script_dir/configs/.p10k.zsh" "$HOME/.p10k.zsh"
      success "Copied .p10k.zsh"
    else
      warn "configs/.p10k.zsh not found, skipping"
    fi
  fi

  # --- Copy eza aliases ---
  if [[ -f "$script_dir/configs/eza.zsh" ]]; then
    cp "$script_dir/configs/eza.zsh" "$HOME/.pretty-terminal-eza.zsh"
    success "Copied eza aliases to ~/.pretty-terminal-eza.zsh"
  else
    warn "configs/eza.zsh not found, skipping"
  fi

  # --- Patch .zshrc ---
  backup_file "$zshrc"

  # Source eza aliases
  if ! grep -qF "source ~/.pretty-terminal-eza.zsh" "$zshrc"; then
    printf '\n# pretty-terminal: eza aliases\nsource ~/.pretty-terminal-eza.zsh\n' >> "$zshrc"
    info "Added eza alias source to .zshrc"
  fi

  # Set Powerlevel10k theme
  if [[ "$no_theme" != "true" ]]; then
    if grep -q '^ZSH_THEME=' "$zshrc"; then
      sed -i.sedtmp 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$zshrc"
      rm -f "$zshrc.sedtmp"
      info "Updated ZSH_THEME to powerlevel10k"
    else
      printf '\nZSH_THEME="powerlevel10k/powerlevel10k"\n' >> "$zshrc"
      info "Added ZSH_THEME to .zshrc"
    fi

    # Source .p10k.zsh
    if ! grep -qF "source ~/.p10k.zsh" "$zshrc"; then
      printf '\n# pretty-terminal: powerlevel10k config\n[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh\n' >> "$zshrc"
      info "Added p10k source to .zshrc"
    fi
  fi

  success "Shell configuration applied"
}

apply_terminal_config() {
  local script_dir="$1"
  local os
  os="$(detect_os)"

  info "Detecting terminal emulator..."

  # --- Ghostty ---
  local ghostty_config_dir
  if [[ "$os" == "macos" ]]; then
    ghostty_config_dir="$HOME/Library/Application Support/com.mitchellh.ghostty"
  else
    ghostty_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
  fi

  if [[ -d "$ghostty_config_dir" ]]; then
    info "Ghostty detected"
    if [[ -f "$script_dir/configs/ghostty.conf" ]]; then
      backup_file "$ghostty_config_dir/config"
      cp "$script_dir/configs/ghostty.conf" "$ghostty_config_dir/config"
      success "Applied Ghostty config"
      return 0
    else
      warn "configs/ghostty.conf not found, skipping"
    fi
  fi

  # --- iTerm2 (macOS only) ---
  if [[ "$os" == "macos" ]]; then
    local iterm_plist="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
    if [[ -f "$iterm_plist" ]]; then
      info "iTerm2 detected"
      if [[ -f "$script_dir/configs/iterm2-profile.json" ]]; then
        info "iTerm2 profile available at configs/iterm2-profile.json"
        info "Import it via iTerm2 > Settings > Profiles > Other Actions > Import JSON Profiles"
        success "iTerm2 config ready for manual import"
        return 0
      else
        warn "configs/iterm2-profile.json not found, skipping"
      fi
    fi
  fi

  warn "No supported terminal config detected (Ghostty, iTerm2)"
  info "You can manually apply configs from the configs/ directory"
}

uninstall() {
  info "Restoring backups..."

  local restored=0

  # Restore files that have .bak versions
  local files_to_restore=(
    "$HOME/.zshrc"
    "$HOME/.p10k.zsh"
  )

  # Add Ghostty config
  local os
  os="$(detect_os)"
  if [[ "$os" == "macos" ]]; then
    files_to_restore+=("$HOME/Library/Application Support/com.mitchellh.ghostty/config")
  else
    files_to_restore+=("${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config")
  fi

  for file in "${files_to_restore[@]}"; do
    if [[ -f "${file}.bak" ]]; then
      cp "${file}.bak" "$file"
      info "Restored $file from backup"
      restored=$((restored + 1))
    fi
  done

  # Remove pretty-terminal specific files
  if [[ -f "$HOME/.pretty-terminal-eza.zsh" ]]; then
    rm "$HOME/.pretty-terminal-eza.zsh"
    info "Removed ~/.pretty-terminal-eza.zsh"
  fi

  # Remove source line from .zshrc
  if [[ -f "$HOME/.zshrc" ]]; then
    sed -i.sedtmp '/pretty-terminal: eza aliases/d' "$HOME/.zshrc"
    sed -i.sedtmp '/source ~\/.pretty-terminal-eza.zsh/d' "$HOME/.zshrc"
    rm -f "$HOME/.zshrc.sedtmp"
    info "Removed eza source line from .zshrc"
  fi

  if [[ "$restored" -eq 0 ]]; then
    warn "No backup files found to restore"
  else
    success "Restored $restored file(s) from backups"
  fi

  success "Uninstall complete"
}
