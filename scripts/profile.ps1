# MyPowerShell Profile
# High-performance PowerShell environment inspired by MyBash
# Version: 2.2.0

# Set root directory
$MyPowerShellRoot = $PSScriptRoot | Split-Path -Parent

# ============================================================================
# 0. Batch Command Availability Check (Performance Optimization)
# ============================================================================
# Cache tool availability to avoid expensive Get-Command calls (~50-100ms saved)
$toolCachePath = "$env:TEMP\mypowershell-tools.json"
$toolCacheMaxAge = 7  # days
$cacheValid = $false

# Try to load from cache if it exists and is fresh
if ([System.IO.File]::Exists($toolCachePath)) {
    $cacheAge = ((Get-Date) - [System.IO.File]::GetLastWriteTime($toolCachePath)).TotalDays
    if ($cacheAge -lt $toolCacheMaxAge) {
        try {
            $cacheData = [System.IO.File]::ReadAllText($toolCachePath) | ConvertFrom-Json
            $script:ToolsAvailable = @{}
            foreach ($prop in $cacheData.PSObject.Properties) {
                $script:ToolsAvailable[$prop.Name] = $prop.Value
            }
            $cacheValid = $true
        } catch {
            # Cache corrupted, will regenerate
        }
    }
}

# If cache invalid or missing, check tools and save to cache
if (-not $cacheValid) {
    # Check all tools in a single Get-Command call
    $foundTools = @(Get-Command -Name starship,zoxide,fzf,eza,bat,fd,rg,yazi -ErrorAction SilentlyContinue)
    $script:ToolsAvailable = @{}
    foreach ($tool in @('starship','zoxide','fzf','eza','bat','fd','rg','yazi')) {
        # Match with or without .exe extension (Windows compatibility)
        $script:ToolsAvailable[$tool] = ($foundTools.Name -contains $tool) -or ($foundTools.Name -contains "$tool.exe")
    }

    # Check module availability (separate from commands)
    $script:ToolsAvailable['PSFzf'] = $null -ne (Get-Module -ListAvailable -Name PSFzf)

    # Save to cache
    try {
        $script:ToolsAvailable | ConvertTo-Json | Set-Content $toolCachePath -Force -ErrorAction Stop
    } catch {
        # Cache save failed, not critical
    }
}

# ============================================================================
# 1. Source Aliases (with tool availability passed)
# ============================================================================
$aliasesPath = Join-Path $MyPowerShellRoot "scripts\aliases.ps1"
if ([System.IO.File]::Exists($aliasesPath)) {
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
        ((Get-Date) - [System.IO.File]::GetLastWriteTime($starshipCache)).TotalDays
    } else { 999 }

    # Regenerate cache if it doesn't exist or is older than 7 days
    if ($cacheAge -ge $toolCacheMaxAge) {
        try {
            $initOutput = starship init powershell --print-full-init
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
        Invoke-Expression (&starship init powershell --print-full-init)
    }
}

# ============================================================================
# 3. Zoxide (Smart Directory Navigation - Cached Init)
# ============================================================================
if ($ToolsAvailable.zoxide) {
    # Cache init script for faster startup (~50ms saved)
    $zoxideCache = "$env:TEMP\mypowershell-zoxide-init.ps1"
    $cacheAge = if ([System.IO.File]::Exists($zoxideCache)) {
        ((Get-Date) - [System.IO.File]::GetLastWriteTime($zoxideCache)).TotalDays
    } else { 999 }

    # Regenerate cache if it doesn't exist or is older than 7 days
    if ($cacheAge -ge $toolCacheMaxAge) {
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
# 4. FZF + PSFzf (Lazy-loaded on first use for faster startup)
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
# 5. PSReadLine (Inline History Prediction / "ghost text")
# ============================================================================
try {
    Set-PSReadLineOption -PredictionSource History -PredictionViewStyle InlineView
} catch {
    # PSReadLine 2.2+ required; silently skip on older installs
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
