#Requires -Version 5.1
[CmdletBinding()]
param(
    [switch]$Uninstall,
    [switch]$FontOnly,
    [switch]$NoTerminal,
    [switch]$NoTheme,
    [switch]$Help,
    [string]$Font = "jetbrains"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Validate Font parameter
$Font = $Font.ToLower()
if ($Font -notin @("jetbrains", "d2coding")) {
    Write-Host "  ERROR: Invalid -Font value '$Font'. Valid options: jetbrains, d2coding" -ForegroundColor Red
    exit 1
}

# Source all lib-win modules
$libDir = Join-Path $PSScriptRoot "lib-win"
foreach ($script in Get-ChildItem -Path $libDir -Filter "*.ps1") {
    . $script.FullName
}

function Show-Banner {
    Write-Host ""
    Write-Host "  ✨ pretty-terminal installer (Windows)" -ForegroundColor Magenta
    Write-Host "  ─────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
}

function Show-Help {
    Write-Host "Usage: .\install.ps1 [options]" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -FontOnly          Install Nerd Font only"
    Write-Host "  -NoTerminal        Skip Windows Terminal config"
    Write-Host "  -NoTheme           Skip Oh My Posh theme installation"
    Write-Host "  -Uninstall         Restore backups and undo changes"
    Write-Host "  -Help              Show this help message"
    Write-Host "  -Font <name>       Font to install: jetbrains (default), d2coding"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\install.ps1                          # Full install (JetBrainsMono)"
    Write-Host "  .\install.ps1 -Font d2coding           # Full install (D2CodingLigature)"
    Write-Host "  .\install.ps1 -FontOnly                # Install font only"
    Write-Host "  .\install.ps1 -NoTerminal              # Skip terminal config"
    Write-Host "  .\install.ps1 -Uninstall               # Restore backups"
    Write-Host ""
}

function Invoke-Uninstall {
    Write-Info "Uninstalling pretty-terminal..."

    $wtPaths = @(
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:APPDATA\Microsoft\Windows Terminal\settings.json"
    )

    foreach ($path in $wtPaths) {
        $backups = Get-ChildItem -Path (Split-Path $path) -Filter "settings.json.bak.*" -ErrorAction SilentlyContinue |
                   Sort-Object LastWriteTime -Descending
        if ($backups) {
            $latest = $backups[0]
            Copy-Item -Path $latest.FullName -Destination $path -Force
            Write-Success "Restored Windows Terminal settings from $($latest.Name)"
            break
        }
    }

    Write-Warn "Note: Installed fonts, scoop packages, and profile entries must be removed manually."
    Write-Success "Uninstall complete."
}

function Show-Summary {
    $fontDisplayName = if ($Font -eq "d2coding") { "D2CodingLigature Nerd Font Mono" } else { "JetBrainsMono Nerd Font" }
    Write-Host ""
    Write-Host "  ─────────────────────────────────────" -ForegroundColor DarkGray
    Write-Success "  Installation complete!"
    Write-Host ""
    Write-Host "  Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Restart Windows Terminal to apply changes"
    Write-Host "  2. Set font to '$fontDisplayName' if not auto-applied"
    Write-Host "  3. Open a new PowerShell session to activate the prompt theme"
    Write-Host ""
}

# ── Main ──────────────────────────────────────────────────────────────────────

Show-Banner

if ($Help) {
    Show-Help
    exit 0
}

if ($Uninstall) {
    Invoke-Uninstall
    exit 0
}

try {
    # Step 1: Nerd Font
    Write-Host "[1/4] Installing Nerd Font..." -ForegroundColor Cyan
    Install-NerdFont -Font $Font

    if ($FontOnly) {
        Write-Host ""
        Write-Success "Font-only install complete."
        exit 0
    }

    # Step 2: eza
    Write-Host ""
    Write-Host "[2/4] Installing eza..." -ForegroundColor Cyan
    Install-Eza

    # Step 3: Oh My Posh
    if (-not $NoTheme) {
        Write-Host ""
        Write-Host "[3/4] Installing Oh My Posh..." -ForegroundColor Cyan
        Install-OhMyPosh
    }
    else {
        Write-Warn "[3/4] Skipping Oh My Posh (-NoTheme)."
    }

    # Step 4: Windows Terminal config
    if (-not $NoTerminal) {
        Write-Host ""
        Write-Host "[4/4] Applying Windows Terminal config..." -ForegroundColor Cyan
        Apply-TerminalConfig -Font $Font
    }
    else {
        Write-Warn "[4/4] Skipping Windows Terminal config (-NoTerminal)."
    }

    Show-Summary
}
catch {
    Write-Host ""
    Write-Host "  ERROR: $_" -ForegroundColor Red
    Write-Host "  Installation did not complete successfully." -ForegroundColor Red
    Write-Host "  Run with -Uninstall to restore backups if needed." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
