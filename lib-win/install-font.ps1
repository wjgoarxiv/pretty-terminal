function Install-NerdFont {
    Write-Info "Checking JetBrainsMono Nerd Font..."

    $userFontsPath = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    $systemFontsPath = "$env:SystemRoot\Fonts"

    $alreadyInstalled = (Test-Path "$userFontsPath\JetBrainsMonoNerdFont-Regular.ttf") -or
                        (Test-Path "$systemFontsPath\JetBrainsMonoNerdFont-Regular.ttf")

    if ($alreadyInstalled) {
        Write-Success "JetBrainsMono Nerd Font is already installed. Skipping."
        return
    }

    Write-Info "Downloading JetBrainsMono Nerd Font..."

    $tempDir = Join-Path $env:TEMP "pretty-terminal-fonts-$(Get-Date -Format 'yyyyMMddHHmmss')"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    $zipPath = Join-Path $tempDir "JetBrainsMono.zip"
    $downloadUrl = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

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
            $regPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
            $fontName = [System.IO.Path]::GetFileNameWithoutExtension($ttf.Name) + " (TrueType)"
            Set-ItemProperty -Path $regPath -Name $fontName -Value $dest -ErrorAction SilentlyContinue
        }

        Write-Success "JetBrainsMono Nerd Font installed ($($ttfFiles.Count) files)."
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
