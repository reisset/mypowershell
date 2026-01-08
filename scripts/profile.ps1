# MyPowerShell Profile
# High-performance PowerShell environment inspired by MyBash

# Set root directory
$MyPowerShellRoot = $PSScriptRoot | Split-Path -Parent

# ============================================================================
# 0. Source Aliases (Phase 2+)
# ============================================================================
$aliasesPath = Join-Path $MyPowerShellRoot "scripts\aliases.ps1"
if (Test-Path $aliasesPath) {
    . $aliasesPath
}

# ============================================================================
# 1. Starship Prompt
# ============================================================================
if (Get-Command starship -ErrorAction SilentlyContinue) {
    $ENV:STARSHIP_CONFIG = "$env:USERPROFILE\.config\starship.toml"
    Invoke-Expression (&starship init powershell)
}

# ============================================================================
# 2. PSReadLine Enhancements (History & Prediction)
# ============================================================================
# Only configure PSReadLine in interactive sessions
if ($Host.UI.RawUI -and (Get-Module -ListAvailable -Name PSReadLine)) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue

    # Predictive IntelliSense from history (only if supported)
    try {
        Set-PSReadLineOption -PredictionSource History -ErrorAction Stop
        Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction Stop
    } catch {
        # Prediction not supported in this terminal, skip
    }

    # Emacs-style editing
    Set-PSReadLineOption -EditMode Emacs -ErrorAction SilentlyContinue

    # No bell
    Set-PSReadLineOption -BellStyle None -ErrorAction SilentlyContinue

    # Better history search
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward -ErrorAction SilentlyContinue
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward -ErrorAction SilentlyContinue
}

# ============================================================================
# 3. Zoxide (Smart Directory Navigation)
# ============================================================================
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# ============================================================================
# 4. FZF + PSFzf (Lazy-loaded on first use for faster startup)
# ============================================================================
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    # PSFzf module lazy-loaded only when needed
    # Use Ctrl+T or Ctrl+R - module loads automatically on first use
    if (Get-Module -ListAvailable -Name PSFzf) {
        # Define lazy-loading function
        function global:Initialize-PSFzf {
            if (-not (Get-Module PSFzf)) {
                Import-Module PSFzf -ErrorAction SilentlyContinue
                Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -ErrorAction SilentlyContinue
                Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r' -ErrorAction SilentlyContinue
            }
        }

        # Set keybindings to trigger lazy-load
        Set-PSReadLineKeyHandler -Key 'Ctrl+t' -ScriptBlock {
            Initialize-PSFzf
            Invoke-FzfTabCompletion
        }

        Set-PSReadLineKeyHandler -Key 'Ctrl+r' -ScriptBlock {
            Initialize-PSFzf
            Invoke-FuzzyHistory
        }
    }
}

# ============================================================================
# 5. Welcome Banner (once per session)
# ============================================================================
if ($Host.UI.RawUI -and -not $env:MYPOWERSHELL_WELCOME_SHOWN) {
    $asciiPath = Join-Path $MyPowerShellRoot "asciiart.txt"
    if (Test-Path $asciiPath) {
        Get-Content $asciiPath | Write-Host -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Type 'tools' for quick reference" -ForegroundColor DarkGray
    }
    $env:MYPOWERSHELL_WELCOME_SHOWN = "1"
}
