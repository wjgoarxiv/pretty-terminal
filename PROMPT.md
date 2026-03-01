# LLM Prompt for pretty-terminal

Use this prompt with any AI coding assistant (Claude, ChatGPT, Cursor, etc.) to automatically install pretty-terminal.

## The Prompt

Copy and paste this exactly:

```
Clone the repository https://github.com/wjgoarxiv/pretty-terminal to my home directory and run the appropriate installer for my operating system. On macOS or Linux, execute: bash ~/pretty-terminal/install.sh. On Windows, execute: & $HOME\pretty-terminal\install.ps1. After installation completes, verify: (1) run 'eza --version' to confirm eza works, (2) run 'zsh -n ~/.p10k.zsh' to check for config errors — if it fails, fix by changing '() {' to '{' on line 12 of ~/.p10k.zsh, (3) if on macOS Terminal.app and the font wasn't auto-applied, guide me to set the font in Terminal > Settings > Profiles > Font. Tell me what to do next.
```

## What the AI Will Do

The AI will:

1. Clone the repository using `git clone`
2. Detect your operating system (macOS, Linux, or Windows)
3. Run the correct installer script
4. Install JetBrainsMono Nerd Font
5. Install eza (modern file lister)
6. Install and configure shell (Powerlevel10k for macOS/Linux, Oh My Posh for Windows)
7. Backup your existing shell configuration
8. Verify eza installation and shell config syntax
9. Apply font to Terminal.app if detected (macOS)
10. Tell you what to do next

## Why Use This?

- **One-command install**: No need to remember multiple steps
- **AI handles complexity**: OS detection, package manager selection, all automatic
- **Safe**: Creates backups before modifying your config
- **Cross-platform**: Works on macOS, Linux, and Windows

## Customization

If you want to skip certain components, modify the prompt:

- **Font only**: Add `--font-only` to the installer command
- **No theme**: Add `--no-theme` to the installer command
- **Uninstall**: Replace `install.sh` with `install.sh --uninstall`

Example:
```
Clone https://github.com/wjgoarxiv/pretty-terminal to ~/pretty-terminal and run: bash ~/pretty-terminal/install.sh --font-only
```

## After Installation

1. **Restart your terminal** — New settings take effect
2. **(Optional) Configure Powerlevel10k**: Run `p10k configure` to customize your prompt
3. **Enjoy!** Your terminal is now beautiful

## Post-Install Verification

After running the installer, these checks confirm everything works:

```bash
eza --version              # Should print version info
zsh -n ~/.p10k.zsh         # Should exit silently (no errors)
```

If `zsh -n ~/.p10k.zsh` shows a parse error, the AI should fix it by changing `() {` to `{` on line 12 of `~/.p10k.zsh`.

## Troubleshooting

If something goes wrong, check the README.md in the cloned repository for detailed troubleshooting steps.
