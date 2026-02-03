# scripts/aliases.ps1
# MyPowerShell Aliases - Modern CLI tool shortcuts
# Version: 2.0.0 (Speedier: Minimal aliases for kept tools only)

# ============================================================================
# MODERN TOOL ALIASES (Learning-First Approach)
# These ADD new commands, they don't replace PowerShell standards
# Standard commands (cd, dir, Get-Process, Get-Content) remain untouched
# ============================================================================

# Tool availability is checked once in profile.ps1 and stored in $script:ToolsAvailable
# This saves ~180ms by avoiding 6 redundant Get-Command checks

# ============================================================================
# Eza (modern ls)
# ============================================================================
if ($ToolsAvailable.eza) {
    function ls { eza --icons $args }
    function ll { eza -al --icons --group-directories-first $args }
    function la { eza -a --icons --group-directories-first $args }
    function lt { eza --tree --level=2 --icons $args }
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
