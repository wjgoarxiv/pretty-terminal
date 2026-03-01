#!/usr/bin/env bash
# Install JetBrainsMono Nerd Font

install_font() {
  info "Checking for JetBrainsMono Nerd Font..."

  local os
  os="$(detect_os)"

  # Determine font directory
  local font_dir
  if [[ "$os" == "macos" ]]; then
    font_dir="$HOME/Library/Fonts"
  else
    font_dir="$HOME/.local/share/fonts"
  fi

  # Check if already installed
  if ls "$font_dir"/JetBrainsMonoNerdFont*.ttf >/dev/null 2>&1; then
    success "JetBrainsMono Nerd Font is already installed"
    return 0
  fi

  info "Downloading JetBrainsMono Nerd Font..."

  local tmp_dir
  tmp_dir="$(mktemp -d)"
  local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"

  if command_exists curl; then
    curl -fsSL "$url" -o "$tmp_dir/JetBrainsMono.tar.xz"
  elif command_exists wget; then
    wget -q "$url" -O "$tmp_dir/JetBrainsMono.tar.xz"
  else
    error "Neither curl nor wget found. Cannot download font."
    rm -rf "$tmp_dir"
    return 1
  fi

  info "Extracting font files..."
  mkdir -p "$tmp_dir/extracted"
  tar -xf "$tmp_dir/JetBrainsMono.tar.xz" -C "$tmp_dir/extracted"

  # Install only .ttf files
  mkdir -p "$font_dir"
  find "$tmp_dir/extracted" -name "*.ttf" -exec cp {} "$font_dir/" \;

  local count
  count="$(find "$tmp_dir/extracted" -name "*.ttf" | wc -l | tr -d ' ')"
  info "Copied $count .ttf files to $font_dir"

  # Refresh font cache on Linux
  if [[ "$os" != "macos" ]] && command_exists fc-cache; then
    info "Refreshing font cache..."
    fc-cache -fv >/dev/null 2>&1
  fi

  # Clean up
  rm -rf "$tmp_dir"

  success "JetBrainsMono Nerd Font installed"
}
