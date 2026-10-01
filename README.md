<a id="top"></a>

<p align="center">
  <img src="cover.png" alt="pretty-terminal: one command to beautify your terminal" width="100%">
</p>

<h1 align="center">pretty-terminal</h1>

<p align="center">
  <em>One command to make your terminal beautiful. Works on macOS, Windows, and Linux.</em>
</p>

<p align="center">
  <b>English</b> | <a href="README.ko.md">한국어</a>
</p>

<p align="center">
  <a href="#quick-start"><b>Quick Start</b></a> ·
  <a href="#what-you-get">What You Get</a> ·
  <a href="#apple-silicon">Apple Silicon</a> ·
  <a href="#customization">Customization</a> ·
  <a href="#troubleshooting">Troubleshooting</a>
</p>

<p align="center">
  <a href="https://github.com/wjgoarxiv/pretty-terminal"><img src="https://img.shields.io/github/stars/wjgoarxiv/pretty-terminal?style=flat-square&logo=github" alt="GitHub stars"></a>
  <a href="./LICENSE"><img src="https://img.shields.io/github/license/wjgoarxiv/pretty-terminal?style=flat-square" alt="License"></a>
  <img src="https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-blue?style=flat-square" alt="Platforms: macOS, Linux, Windows">
  <img src="https://img.shields.io/badge/Apple%20Silicon-native%20arm64-black?style=flat-square&logo=apple&logoColor=white" alt="Apple Silicon: native arm64">
</p>

---

<a id="what-you-get"></a>

## ✨ What You Get

| Component | What it adds |
|-----------|--------------|
| 🔤 **JetBrainsMono Nerd Font** | Beautiful monospace font with icon support (or D2CodingLigature Nerd Font Mono for Korean) |
| 📂 **eza** | Modern, colorful file listing with icons and tree view |
| 🐚 **Oh My Zsh + Powerlevel10k** (macOS/Linux) | Clean, minimal prompt with git status |
| 🪟 **Oh My Posh** (Windows) | Modern shell prompt with themes |
| 🍎 **Native on Apple Silicon** | Always installed as arm64, never x86_64 |

<p align="center">
  <img src="preview.png" alt="Before and After" width="100%">
</p>

<a id="quick-start"></a>

## 🚀 Quick Start

> [!IMPORTANT]
> **On an Apple Silicon Mac, everything is installed as native arm64 — never x86_64.** See [Apple Silicon](#apple-silicon).

### Using an LLM (Recommended)

Paste this into Claude, ChatGPT, or any AI assistant:

```
Clone https://github.com/wjgoarxiv/pretty-terminal to my home directory and run the installer for my operating system.
On an Apple Silicon Mac, run it natively: uname -m must print arm64, never x86_64.
```

The AI will handle the rest automatically.

### Manual Install

**macOS / Linux:**
```bash
git clone https://github.com/wjgoarxiv/pretty-terminal.git ~/pretty-terminal
bash ~/pretty-terminal/install.sh
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/wjgoarxiv/pretty-terminal.git $HOME\pretty-terminal
& $HOME\pretty-terminal\install.ps1
```

After installation, restart your terminal.

<a id="apple-silicon"></a>

## 🍎 Apple Silicon

On an Apple Silicon Mac the installer never sets up x86_64 binaries. It detects Apple Silicon from the hardware, not from the shell's architecture, so a Rosetta terminal does not lead to an Intel install.

| Situation | What `install.sh` does |
|-----------|------------------------|
| Started from a Rosetta (x86_64) terminal | Re-launches itself with `arch -arm64` before installing anything |
| Native Homebrew in `/opt/homebrew` exists | Puts it first in `PATH` for the installer run, even if an Intel Homebrew is also installed |
| Only Intel Homebrew in `/usr/local` exists | Stops and asks you to install native Homebrew |
| An x86_64 `eza` is already installed | Replaces it with a native build instead of skipping it |
| Linux, Intel Macs, Windows | Nothing changes |

Check your setup:

```bash
uname -m           # must print arm64
brew --prefix      # should print /opt/homebrew
```

## 📦 What Gets Installed

| Component | macOS | Linux | Windows |
|-----------|:-----:|:-----:|:-------:|
| JetBrainsMono Nerd Font | ✓ | ✓ | ✓ |
| eza (modern ls) | ✓ | ✓ | ✓ |
| Oh My Zsh | ✓ | ✓ | — |
| Powerlevel10k | ✓ | ✓ | — |
| Oh My Posh | — | — | ✓ |

## 🖥️ Supported Terminals

- **macOS**: iTerm2, Ghostty (automatic config), Terminal.app (font auto-applied via AppleScript). Other terminals: set font manually in preferences.
- **Linux**: Ghostty (automatic config applied); for GNOME Terminal, Konsole, and other terminals, set JetBrainsMono Nerd Font manually in your terminal preferences
- **Windows**: Windows Terminal (recommended)

The installer detects your OS and installs components compatible with your system.

## 🎛️ Installation Options

The installer provides these options (add as flags to `install.sh` or `install.ps1`):

| Option | Description |
|--------|-------------|
| `--font-only` | Install only the Nerd Font, skip other components |
| `--font d2coding` | Use D2CodingLigature Nerd Font Mono instead of JetBrainsMono (Korean support) |
| `--no-theme` | Skip theme and shell configuration |
| `--uninstall` | Restore original shell configs from backups |

### macOS / Linux Example:
```bash
bash ~/pretty-terminal/install.sh --font-only
bash ~/pretty-terminal/install.sh --font d2coding    # Use Korean font
```

### Windows Example:
```powershell
& $HOME\pretty-terminal\install.ps1 -FontOnly
& $HOME\pretty-terminal\install.ps1 -Font d2coding   # Use Korean font
```

## ⚙️ What the Installer Does

### On macOS / Linux

1. **Downloads and installs JetBrainsMono Nerd Font** to `~/.local/share/fonts` (Linux) or `~/Library/Fonts` (macOS)
2. **Installs eza** via your system package manager:
   - macOS: Homebrew (`brew install eza`)
   - Ubuntu/Debian: APT with custom repo
   - Fedora/RHEL: DNF
   - Arch: Pacman
3. **Installs Oh My Zsh** (if not already present)
4. **Installs Powerlevel10k** theme
5. **Sets zsh as default shell**
6. **Backs up existing shell configs** (`.zshrc`, `.bashrc`, etc.) with `.bak` suffix

### On Windows

1. **Downloads and installs JetBrainsMono Nerd Font** to user fonts directory
2. **Installs Scoop package manager** (if not present)
3. **Installs eza via Scoop**
4. **Registers font in Windows registry** for system-wide availability

## 🧹 Uninstall

To restore your original terminal configuration:

**macOS / Linux:**
```bash
bash ~/pretty-terminal/install.sh --uninstall
```

**Windows:**
```powershell
& $HOME\pretty-terminal\install.ps1 -Uninstall
```

This restores backed-up configs and removes installed packages (if you choose).

<a id="troubleshooting"></a>

## 🩺 Troubleshooting

### x86_64 tools on Apple Silicon

1. Check the terminal: `uname -m` must print `arm64`
2. Check the tool: `file "$(command -v eza)"` must mention `arm64`
3. If either fails, open a native (non-Rosetta) terminal and rerun the installer; it replaces an x86_64 `eza` with a native build

### Font not showing in terminal

1. **Restart your terminal** after installation
2. **Select JetBrainsMono Nerd Font** (or D2CodingLigature Nerd Font Mono if installed with `--font d2coding`) in terminal preferences
3. On **Windows**: Restart Windows Terminal after font installation
4. On **macOS Terminal.app**: Go to Terminal > Settings > Profiles > select your profile > click "Change..." next to Font > search for "JetBrainsMono Nerd Font" (or "D2CodingLigature Nerd Font Mono" if using `--font d2coding`)

### Command not found: eza

1. Verify installation: `eza --version`
2. If missing, run installer again
3. On **macOS**: Ensure Homebrew is installed (`brew --version`)
4. On **Windows**: Ensure Scoop is installed (`scoop --version`)

### Permission denied on install.sh

Run with bash explicitly:
```bash
bash ~/pretty-terminal/install.sh
```

Or make it executable first:
```bash
chmod +x ~/pretty-terminal/install.sh
bash ~/pretty-terminal/install.sh
```

<a id="customization"></a>

## 🎨 Customization

### eza Aliases

Once installed, these aliases are available:

```bash
ls   # eza --tree --icons --level=1
ll   # eza -la --icons
lt   # eza --tree --icons
la   # eza -a --icons
```

Add your own aliases by editing `~/.zshrc` (macOS/Linux) or PowerShell profile (Windows).

### Powerlevel10k Configuration

Run the Powerlevel10k wizard anytime:

```bash
p10k configure
```

This opens an interactive configuration wizard for customizing your prompt.

## 📋 System Requirements

- **macOS**: 10.14+ (Apple Silicon: native arm64 only, see [Apple Silicon](#apple-silicon))
- **Linux**: Ubuntu 18.04+, Fedora 32+, Arch, or compatible distro
- **Windows**: Windows 10 21H2+ (Windows 11 recommended)
- **Bash/Zsh** (macOS, Linux) or **PowerShell 7+** (Windows)

## 🤝 Contributing

Found an issue? Have a suggestion?

1. Check existing issues on GitHub
2. Open a new issue with details about your OS and terminal
3. Include the output of `bash ~/pretty-terminal/install.sh` or `& $HOME\pretty-terminal\install.ps1`

## 📄 License

MIT License — see LICENSE file for details.

---

<p align="center">
  <a href="#top">Back to top</a> ·
  <a href="#quick-start">Quick Start</a> ·
  <a href="#troubleshooting">Troubleshooting</a> ·
  <a href="https://github.com/wjgoarxiv/pretty-terminal/issues">Issues</a> ·
  <a href="./LICENSE">License</a>
</p>

---

**Made with ❤️ to make your terminal beautiful.**
