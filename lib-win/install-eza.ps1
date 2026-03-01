function Install-Eza {
    Write-Info "Checking eza..."

    if (Test-Command "eza") {
        Write-Success "eza is already installed. Skipping."
        return
    }

    # Ensure scoop is available
    if (-not (Test-Command "scoop")) {
        Write-Info "Scoop not found. Installing scoop..."
        try {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Invoke-RestMethod get.scoop.sh | Invoke-Expression
            Write-Success "Scoop installed."
        }
        catch {
            Write-Err "Failed to install scoop: $_"
            throw
        }
    }
    else {
        Write-Info "Scoop is already installed."
    }

    Write-Info "Installing eza via scoop..."
    try {
        scoop install eza
        Write-Success "eza installed."
    }
    catch {
        Write-Err "Failed to install eza: $_"
        throw
    }
}
