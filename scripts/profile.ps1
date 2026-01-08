# MyPowerShell Profile
# High-performance PowerShell environment inspired by MyBash
# Version: 1.1.0 (Performance Optimized)

# Set root directory
$MyPowerShellRoot = $PSScriptRoot | Split-Path -Parent

# ============================================================================
# 0. Batch Command Availability Check (Performance Optimization)
# ============================================================================
# Check all tools once instead of individually (~150ms saved)
$script:ToolsAvailable = @{
    starship = $null -ne (Get-Command starship -ErrorAction SilentlyContinue)
    zoxide   = $null -ne (Get-Command zoxide -ErrorAction SilentlyContinue)
    fzf      = $null -ne (Get-Command fzf -ErrorAction SilentlyContinue)
    eza      = $null -ne (Get-Command eza -ErrorAction SilentlyContinue)
    bat      = $null -ne (Get-Command bat -ErrorAction SilentlyContinue)
    fd       = $null -ne (Get-Command fd -ErrorAction SilentlyContinue)
    rg       = $null -ne (Get-Command rg -ErrorAction SilentlyContinue)
    lazygit  = $null -ne (Get-Command lazygit -ErrorAction SilentlyContinue)
    yazi     = $null -ne (Get-Command yazi -ErrorAction SilentlyContinue)
}

# ============================================================================
# 1. Source Aliases (with tool availability passed)
# ============================================================================
$aliasesPath = Join-Path $MyPowerShellRoot "scripts\aliases.ps1"
if (Test-Path $aliasesPath) {
    . $aliasesPath
}

# ============================================================================
# 2. Starship Prompt (Cached Init Script)
# ============================================================================
if ($ToolsAvailable.starship) {
    $ENV:STARSHIP_CONFIG = "$env:USERPROFILE\.config\starship.toml"

    # Cache init script for faster startup (~50ms saved)
    $starshipCache = "$env:TEMP\mypowershell-starship-init.ps1"
    $cacheAge = if (Test-Path $starshipCache) {
        ((Get-Date) - (Get-Item $starshipCache).LastWriteTime).Days
    } else { 999 }

    # Regenerate cache if it doesn't exist or is older than 7 days
    if ($cacheAge -gt 7) {
        starship init powershell | Set-Content $starshipCache -Force
    }

    # Source cached init script
    . $starshipCache
}

# ============================================================================
# 3. PSReadLine Enhancements (History & Prediction)
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
# 4. Zoxide (Smart Directory Navigation - Cached Init)
# ============================================================================
if ($ToolsAvailable.zoxide) {
    # Cache init script for faster startup (~50ms saved)
    $zoxideCache = "$env:TEMP\mypowershell-zoxide-init.ps1"
    $cacheAge = if (Test-Path $zoxideCache) {
        ((Get-Date) - (Get-Item $zoxideCache).LastWriteTime).Days
    } else { 999 }

    # Regenerate cache if it doesn't exist or is older than 7 days
    if ($cacheAge -gt 7) {
        zoxide init powershell | Set-Content $zoxideCache -Force
    }

    # Source cached init script
    . $zoxideCache
}

# ============================================================================
# 5. FZF + PSFzf (Lazy-loaded on first use for faster startup)
# ============================================================================
if ($ToolsAvailable.fzf) {
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
# 6. Yazi File Manager Wrapper (allows cwd change)
# ============================================================================
if ($ToolsAvailable.yazi) {
    function y {
        $tmp = [System.IO.Path]::GetTempFileName()
        yazi $args --cwd-file="$tmp"
        $cwd = Get-Content -Path $tmp -ErrorAction SilentlyContinue
        if ($cwd -and $cwd -ne $PWD.Path) {
            Set-Location -Path $cwd
        }
        Remove-Item -Path $tmp -ErrorAction SilentlyContinue
    }
}

# ============================================================================
# 7. Welcome Banner (once per session)
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
