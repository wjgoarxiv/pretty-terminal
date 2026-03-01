function Apply-TerminalConfig {
    param(
        [string]$Font = "jetbrains"
    )

    $fontFaceName = if ($Font -eq "d2coding") { "D2CodingLigature Nerd Font Mono" } else { "JetBrainsMono Nerd Font" }

    Write-Info "Applying Windows Terminal configuration..."

    # Locate Windows Terminal settings.json
    $wtPaths = @(
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:APPDATA\Microsoft\Windows Terminal\settings.json"
    )

    $settingsPath = $null
    foreach ($path in $wtPaths) {
        if (Test-Path $path) {
            $settingsPath = $path
            break
        }
    }

    if ($null -eq $settingsPath) {
        Write-Warn "Windows Terminal settings.json not found. Skipping terminal config."
        return
    }

    Write-Info "Found Windows Terminal settings at: $settingsPath"

    # Backup existing settings
    Backup-File -Path $settingsPath | Out-Null

    # Read existing settings
    try {
        $settingsRaw = Get-Content $settingsPath -Raw -Encoding UTF8
        $settings = $settingsRaw | ConvertFrom-Json
    }
    catch {
        Write-Err "Failed to parse settings.json: $_"
        throw
    }

    # Dracula color scheme definition
    $draculaScheme = [PSCustomObject]@{
        name                = "Dracula"
        background          = "#282A36"
        foreground          = "#F8F8F2"
        cursorColor         = "#F8F8F2"
        selectionBackground = "#44475A"
        black               = "#21222C"
        blue                = "#BD93F9"
        brightBlack         = "#6272A4"
        brightBlue          = "#D6ACFF"
        brightCyan          = "#A4FFFF"
        brightGreen         = "#69FF94"
        brightPurple        = "#FF92DF"
        brightRed           = "#FF6E6E"
        brightWhite         = "#FFFFFF"
        brightYellow        = "#FFFFA5"
        cyan                = "#8BE9FD"
        green               = "#50FA7B"
        purple              = "#FF79C6"
        red                 = "#FF5555"
        white               = "#F8F8F2"
        yellow              = "#F1FA8C"
    }

    # Merge color scheme — add Dracula if not already present
    if ($null -eq $settings.schemes) {
        $settings | Add-Member -MemberType NoteProperty -Name "schemes" -Value @() -Force
    }

    $existingScheme = $settings.schemes | Where-Object { $_.name -eq "Dracula" }
    if ($null -eq $existingScheme) {
        $settings.schemes += $draculaScheme
        Write-Success "Dracula color scheme added."
    }
    else {
        Write-Info "Dracula color scheme already present. Skipping."
    }

    # Apply font and color scheme to default profile
    if ($null -eq $settings.profiles) {
        $settings | Add-Member -MemberType NoteProperty -Name "profiles" -Value ([PSCustomObject]@{ defaults = [PSCustomObject]@{} }) -Force
    }
    if ($null -eq $settings.profiles.defaults) {
        $settings.profiles | Add-Member -MemberType NoteProperty -Name "defaults" -Value ([PSCustomObject]@{}) -Force
    }

    $defaults = $settings.profiles.defaults

    # Set font face
    if ($null -eq $defaults.font) {
        $defaults | Add-Member -MemberType NoteProperty -Name "font" -Value ([PSCustomObject]@{ face = $fontFaceName }) -Force
    }
    else {
        $defaults.font | Add-Member -MemberType NoteProperty -Name "face" -Value $fontFaceName -Force
    }

    # Set color scheme
    $defaults | Add-Member -MemberType NoteProperty -Name "colorScheme" -Value "Dracula" -Force

    Write-Info "Font set to $fontFaceName, color scheme set to Dracula."

    # Write updated settings back
    try {
        $updatedJson = $settings | ConvertTo-Json -Depth 20
        Set-Content -Path $settingsPath -Value $updatedJson -Encoding UTF8
        Write-Success "Windows Terminal settings updated."
    }
    catch {
        Write-Err "Failed to write settings.json: $_"
        throw
    }
}
