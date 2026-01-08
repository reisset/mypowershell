# scripts/aliases.ps1
# MyPowerShell Aliases - Modern CLI tool shortcuts
# Version: 1.1.0 (Performance Optimized - uses cached tool availability)

# ============================================================================
# MODERN TOOL ALIASES (Learning-First Approach)
# These ADD new commands, they don't replace PowerShell standards
# Standard commands (cd, dir, Get-Process, Get-Content) remain untouched
# ============================================================================

# Tool availability is checked once in profile.ps1 and stored in $script:ToolsAvailable
# This saves ~180ms by avoiding 6 redundant Get-Command checks

# ============================================================================
# Eza (modern ls) - with glob workaround for Windows
# ============================================================================
if ($ToolsAvailable.eza) {
    function ls { eza --icons $args }
    function ll { eza -al --icons --group-directories-first $args }
    function la { eza -a --icons --group-directories-first $args }
    function lt { eza --tree --level=2 --icons $args }

    # Glob workaround: Windows doesn't expand wildcards like Linux
    # Use: lsg "*.txt" instead of: eza *.txt (which fails)
    function lsg {
        param([string]$Pattern = "*")
        Get-ChildItem -Name $Pattern | ForEach-Object { eza --icons $_ }
    }
}

# ============================================================================
# Bat (modern cat with syntax highlighting)
# ============================================================================
if ($ToolsAvailable.bat) {
    Set-Alias -Name cat -Value bat -Option AllScope -ErrorAction SilentlyContinue
    # Note: Get-Content is still available as 'gc' (PowerShell default alias)
}

# ============================================================================
# Ripgrep (better grep)
# ============================================================================
if ($ToolsAvailable.rg) {
    Set-Alias -Name grep -Value rg -Option AllScope -ErrorAction SilentlyContinue
    # Note: Select-String is still available as 'sls' (PowerShell default alias)
}

# ============================================================================
# Fd (better find)
# ============================================================================
if ($ToolsAvailable.fd) {
    Set-Alias -Name find -Value fd -Option AllScope -ErrorAction SilentlyContinue
    # Note: Get-ChildItem -Recurse still works for standard searching
}

# ============================================================================
# Navigation Shortcuts
# ============================================================================
function .. { Set-Location .. }
function ... { Set-Location ..\.. }
function .... { Set-Location ..\..\.. }

# Zoxide interactive mode
if ($ToolsAvailable.zoxide) {
    function zi { z -i $args }  # Interactive directory picker
}

# ============================================================================
# Git Shortcuts
# ============================================================================
Set-Alias -Name g -Value git -ErrorAction SilentlyContinue
function gs { git status $args }
function ga { git add $args }
function gc { git commit $args }
function gp { git push $args }
function gl { git pull $args }
function gd { git diff $args }

# ============================================================================
# Development Tools
# ============================================================================

# LazyGit - Git TUI
if ($ToolsAvailable.lazygit) {
    Set-Alias -Name lg -Value lazygit -ErrorAction SilentlyContinue
}

# Dust - Disk usage (no alias needed, command is already 'dust')
# Standard: Get-PSDrive, or Windows Explorer properties

# ============================================================================
# Quick Reference Guide
# ============================================================================
function tools {
    $MyPowerShellRoot = $PSScriptRoot | Split-Path -Parent
    $toolsPath = Join-Path $MyPowerShellRoot "docs\TOOLS.md"

    if (Test-Path $toolsPath) {
        # Use bat if available, otherwise fallback to Get-Content
        if ($ToolsAvailable.bat) {
            bat $toolsPath
        } elseif (Get-Command glow -ErrorAction SilentlyContinue) {
            glow $toolsPath
        } else {
            Get-Content $toolsPath
        }
    } else {
        Write-Host "TOOLS.md not found at $toolsPath" -ForegroundColor Yellow
        Write-Host "Run the full installer to get documentation." -ForegroundColor Gray
    }
}

# ============================================================================
# OPTIONAL: POWER MODE (Uncomment to fully replace standard commands)
# WARNING: This breaks muscle memory for vanilla Windows systems!
# ============================================================================
# Remove-Alias -Name cd -Force -ErrorAction SilentlyContinue
# Set-Alias -Name cd -Value z -Option AllScope
#
# Note: Other aliases (grep, find, cat) are already set above
# ============================================================================
