#!/usr/bin/env bash
# Install Nerd Font (JetBrainsMono or D2Coding)

install_font() {
  local font_choice="${1:-jetbrains}"

  local url font_pattern font_name archive_name
  if [[ "$font_choice" == "d2coding" ]]; then
    url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/D2Coding.tar.xz"
    font_pattern="D2CodingLigatureNerdFontMono*.ttf"
    font_name="D2CodingLigature Nerd Font Mono"
    archive_name="D2Coding.tar.xz"
  else
    url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
    font_pattern="JetBrainsMonoNerdFont*.ttf"
    font_name="JetBrainsMono Nerd Font"
    archive_name="JetBrainsMono.tar.xz"
  fi

  info "Checking for $font_name..."

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
  if ls "$font_dir"/$font_pattern >/dev/null 2>&1; then
    success "$font_name is already installed"
    return 0
  fi

  info "Downloading $font_name..."

  local tmp_dir
  tmp_dir="$(mktemp -d)"

  if command_exists curl; then
    curl -fsSL "$url" -o "$tmp_dir/$archive_name"
  elif command_exists wget; then
    wget -q "$url" -O "$tmp_dir/$archive_name"
  else
    error "Neither curl nor wget found. Cannot download font."
    rm -rf "$tmp_dir"
    return 1
  fi

  info "Extracting font files..."
  mkdir -p "$tmp_dir/extracted"
  tar -xf "$tmp_dir/$archive_name" -C "$tmp_dir/extracted"

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

  success "$font_name installed"
}
