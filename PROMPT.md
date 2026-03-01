# LLM Prompt for pretty-terminal

Use this prompt with any AI coding assistant (Claude, ChatGPT, Cursor, etc.) to automatically install pretty-terminal.

## The Prompt

Copy and paste this exactly:

```
Clone the repository https://github.com/wjgoarxiv/pretty-terminal to my home directory and run the appropriate installer for my operating system. On macOS or Linux, execute: bash ~/pretty-terminal/install.sh. On Windows, execute: & $HOME\pretty-terminal\install.ps1. After installation completes, tell me what to do next.
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
8. Tell you to restart your terminal

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

## Troubleshooting

If something goes wrong, check the README.md in the cloned repository for detailed troubleshooting steps.
