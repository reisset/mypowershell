# MyPowerShell Profile
# High-performance PowerShell environment inspired by MyBash
# Version: 1.2.2 (Bug fix: Cache error handling + fallback)

# Set root directory
$MyPowerShellRoot = $PSScriptRoot | Split-Path -Parent

# ============================================================================
# 0. Batch Command Availability Check (Performance Optimization)
# ============================================================================
# Check all tools in a single Get-Command call (~180ms saved)
# Force array with @() to ensure consistent behavior
$foundTools = @(Get-Command -Name starship,zoxide,fzf,eza,bat,fd,rg,lazygit,yazi,glow -ErrorAction SilentlyContinue)
$script:ToolsAvailable = @{}
foreach ($tool in @('starship','zoxide','fzf','eza','bat','fd','rg','lazygit','yazi','glow')) {
    # Match with or without .exe extension (Windows compatibility)
    $script:ToolsAvailable[$tool] = ($foundTools.Name -contains $tool) -or ($foundTools.Name -contains "$tool.exe")
}

# Check module availability (separate from commands)
$script:ToolsAvailable['PSFzf'] = $null -ne (Get-Module -ListAvailable -Name PSFzf)

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
    $cacheAge = if ([System.IO.File]::Exists($starshipCache)) {
        ((Get-Date) - [System.IO.File]::GetLastWriteTime($starshipCache)).Days
    } else { 999 }

    # Regenerate cache if it doesn't exist or is older than 7 days
    if ($cacheAge -gt 7) {
        try {
            $initOutput = starship init powershell
            if ($initOutput) {
                $initOutput | Set-Content $starshipCache -Force -ErrorAction Stop
            }
        } catch {
            # Cache creation failed, will fall back to direct init
        }
    }

    # Source cached script OR run direct init as fallback
    if ([System.IO.File]::Exists($starshipCache)) {
        . $starshipCache
    } else {
        Invoke-Expression (&starship init powershell)
    }
}

# ============================================================================
# 3. PSReadLine Enhancements (History & Prediction)
# ============================================================================
# Only configure PSReadLine in interactive sessions
# Note: PSReadLine is built-in to PowerShell 5.1+, no availability check needed
if ($Host.UI.RawUI) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue

    # Predictive IntelliSense from history (only if supported)
    try {
        Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView -ErrorAction Stop
    } catch {
        # Prediction not supported in this terminal, skip
    }

    # Other PSReadLine options (combined for performance)
    Set-PSReadLineOption -EditMode Emacs -BellStyle None -ErrorAction SilentlyContinue

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
    $cacheAge = if ([System.IO.File]::Exists($zoxideCache)) {
        ((Get-Date) - [System.IO.File]::GetLastWriteTime($zoxideCache)).Days
    } else { 999 }

    # Regenerate cache if it doesn't exist or is older than 7 days
    if ($cacheAge -gt 7) {
        try {
            $initOutput = zoxide init powershell
            if ($initOutput) {
                $initOutput | Set-Content $zoxideCache -Force -ErrorAction Stop
            }
        } catch {
            # Cache creation failed, will fall back to direct init
        }
    }

    # Source cached script OR run direct init as fallback
    if ([System.IO.File]::Exists($zoxideCache)) {
        . $zoxideCache
    } else {
        Invoke-Expression (&zoxide init powershell)
    }
}

# ============================================================================
# 5. FZF + PSFzf (Lazy-loaded on first use for faster startup)
# ============================================================================
if ($ToolsAvailable.fzf) {
    # PSFzf module lazy-loaded only when needed
    # Use Ctrl+T or Ctrl+R - module loads automatically on first use
    if ($ToolsAvailable.PSFzf) {
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
    if ([System.IO.File]::Exists($asciiPath)) {
        [System.IO.File]::ReadAllLines($asciiPath) | Write-Host -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Type 'tools' for quick reference" -ForegroundColor DarkGray
    }
    $env:MYPOWERSHELL_WELCOME_SHOWN = "1"
}
