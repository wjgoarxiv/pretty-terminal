function Install-NerdFont {
    param(
        [string]$Font = "jetbrains"
    )

    # Resolve font-specific properties
    if ($Font -eq "d2coding") {
        $fontDisplayName = "D2CodingLigature Nerd Font Mono"
        $checkFile       = "D2CodingLigatureNerdFontMono-Regular.ttf"
        $downloadUrl     = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/D2Coding.zip"
        $zipName         = "D2Coding.zip"
    }
    else {
        $fontDisplayName = "JetBrainsMono Nerd Font"
        $checkFile       = "JetBrainsMonoNerdFont-Regular.ttf"
        $downloadUrl     = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
        $zipName         = "JetBrainsMono.zip"
    }

    Write-Info "Checking $fontDisplayName..."

    $userFontsPath   = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    $systemFontsPath = "$env:SystemRoot\Fonts"

    $alreadyInstalled = (Test-Path "$userFontsPath\$checkFile") -or
                        (Test-Path "$systemFontsPath\$checkFile")

    if ($alreadyInstalled) {
        Write-Success "$fontDisplayName is already installed. Skipping."
        return
    }

    Write-Info "Downloading $fontDisplayName..."

    $tempDir = Join-Path $env:TEMP "pretty-terminal-fonts-$(Get-Date -Format 'yyyyMMddHHmmss')"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    $zipPath = Join-Path $tempDir $zipName

    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing
        Write-Info "Extracting font archive..."
        Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force

        if (-not (Test-Path $userFontsPath)) {
            New-Item -ItemType Directory -Path $userFontsPath -Force | Out-Null
        }

        $ttfFiles = Get-ChildItem -Path $tempDir -Filter "*.ttf" -Recurse
        foreach ($ttf in $ttfFiles) {
            $dest = Join-Path $userFontsPath $ttf.Name
            Copy-Item -Path $ttf.FullName -Destination $dest -Force

            # Register font in registry for user-scope installation
            $regPath  = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
            $fontName = [System.IO.Path]::GetFileNameWithoutExtension($ttf.Name) + " (TrueType)"
            Set-ItemProperty -Path $regPath -Name $fontName -Value $dest -ErrorAction SilentlyContinue
        }

        Write-Success "$fontDisplayName installed ($($ttfFiles.Count) files)."
    }
    catch {
        Write-Err "Failed to install font: $_"
        throw
    }
    finally {
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Info "Cleaned up temp files."
    }
}
