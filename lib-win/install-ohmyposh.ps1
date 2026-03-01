function Install-OhMyPosh {
    Write-Info "Checking Oh My Posh..."

    if (-not (Test-Command "oh-my-posh")) {
        Write-Info "Installing Oh My Posh..."

        $installed = $false

        # Try winget first
        if (Test-Command "winget") {
            try {
                winget install JanDeDobbeleer.OhMyPosh -s winget --accept-package-agreements --accept-source-agreements
                $installed = $true
                Write-Success "Oh My Posh installed via winget."
            }
            catch {
                Write-Warn "winget install failed, falling back to scoop..."
            }
        }

        # Fall back to scoop
        if (-not $installed) {
            if (-not (Test-Command "scoop")) {
                Write-Warn "Neither winget nor scoop available. Skipping Oh My Posh installation."
                return
            }
            try {
                scoop install oh-my-posh
                Write-Success "Oh My Posh installed via scoop."
            }
            catch {
                Write-Err "Failed to install Oh My Posh: $_"
                throw
            }
        }
    }
    else {
        Write-Success "Oh My Posh is already installed. Skipping."
    }

    # Copy theme config
    $themeSource = Join-Path $PSScriptRoot "..\configs\ohmyposh-theme.json"
    $themeSource = [System.IO.Path]::GetFullPath($themeSource)
    $themeDir = "$env:USERPROFILE\.config\oh-my-posh"
    $themeDest = Join-Path $themeDir "pretty-terminal.json"

    if (Test-Path $themeSource) {
        if (-not (Test-Path $themeDir)) {
            New-Item -ItemType Directory -Path $themeDir -Force | Out-Null
        }
        Copy-Item -Path $themeSource -Destination $themeDest -Force
        Write-Success "Oh My Posh theme copied to $themeDest"
    }
    else {
        Write-Warn "Theme file not found at $themeSource — skipping theme copy."
    }

    # Add Oh My Posh init to PowerShell profile
    $profilePath = $PROFILE.CurrentUserCurrentHost
    $profileDir = Split-Path $profilePath
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
    if (-not (Test-Path $profilePath)) {
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
    }

    $ompInit = @'

# Oh My Posh — pretty-terminal
oh-my-posh init pwsh --config ~/.config/oh-my-posh/pretty-terminal.json | Invoke-Expression
'@

    $ompAliases = @'

# eza aliases — pretty-terminal
Set-Alias -Name ls -Value eza-ls -Option AllScope
function eza-ls { eza --tree --icons --level=1 @args }
function ll { eza -la --icons @args }
function lt { eza --tree --icons @args }
function la { eza -a --icons @args }
'@

    $profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
    if ($null -eq $profileContent) { $profileContent = "" }

    if ($profileContent -notmatch "oh-my-posh init pwsh") {
        Add-Content -Path $profilePath -Value $ompInit
        Write-Success "Oh My Posh init added to PowerShell profile."
    }
    else {
        Write-Info "Oh My Posh init already present in profile. Skipping."
    }

    if ($profileContent -notmatch "eza-ls") {
        Add-Content -Path $profilePath -Value $ompAliases
        Write-Success "eza aliases added to PowerShell profile."
    }
    else {
        Write-Info "eza aliases already present in profile. Skipping."
    }
}
