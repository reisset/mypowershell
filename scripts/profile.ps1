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
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue

    # Predictive IntelliSense from history
    Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
    Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue

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
# 4. FZF + PSFzf (Fuzzy Finder)
# ============================================================================
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    # Import PSFzf module if available
    if (Get-Module -ListAvailable -Name PSFzf) {
        Import-Module PSFzf -ErrorAction SilentlyContinue

        # Keybindings: Ctrl+R for history, Ctrl+T for file finder
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -ErrorAction SilentlyContinue
        Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r' -ErrorAction SilentlyContinue
    }
}

# ============================================================================
# 5. Terminal Icons (Phase 3 - will be added later)
# ============================================================================
# if (Get-Module -ListAvailable -Name Terminal-Icons) {
#     Import-Module Terminal-Icons -ErrorAction SilentlyContinue
# }
