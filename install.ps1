#Requires -Version 5.1
<#
.SYNOPSIS
    MyPowerShell Installer - High-performance PowerShell environment for Windows
.DESCRIPTION
    Installs modern CLI tools and configurations inspired by MyBash for Linux.
    Phase 2: Core Tools (zoxide, fzf, eza, bat, fd, ripgrep + aliases)
.NOTES
    Version: 1.0.0-phase2
    No administrator privileges required
#>

param(
    [switch]$SkipConfirmation
)

# ============================================================================
# Helper Functions
# ============================================================================

function Write-Status {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Type = 'Info'
    )

    $color = switch ($Type) {
        'Info'    { 'Cyan' }
        'Success' { 'Green' }
        'Warning' { 'Yellow' }
        'Error'   { 'Red' }
    }

    $prefix = switch ($Type) {
        'Info'    { '[*]' }
        'Success' { '[✓]' }
        'Warning' { '[!]' }
        'Error'   { '[✗]' }
    }

    Write-Host "$prefix $Message" -ForegroundColor $color
}

function Test-CommandExists {
    param([string]$Command)
    return $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Confirm {
    param(
        [string]$Message,
        [bool]$DefaultYes = $true
    )

    if ($SkipConfirmation) { return $true }

    $prompt = if ($DefaultYes) { "$Message [Y/n]" } else { "$Message [y/N]" }
    $response = Read-Host $prompt

    if ([string]::IsNullOrWhiteSpace($response)) {
        return $DefaultYes
    }

    return $response -match '^[Yy]'
}

function Install-WingetPackage {
    param(
        [string]$Id,
        [string]$CommandName
    )

    if (Test-CommandExists $CommandName) {
        Write-Status "$CommandName is already installed" -Type Success
        return $true
    }

    Write-Status "Installing $CommandName via winget..." -Type Info
    try {
        $result = winget install --id $Id --source winget --accept-source-agreements --accept-package-agreements 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Status "$CommandName installed successfully" -Type Success
            return $true
        } else {
            Write-Status "winget install failed for $CommandName" -Type Warning
            return $false
        }
    } catch {
        Write-Status "Error installing $CommandName via winget: $_" -Type Warning
        return $false
    }
}

function Install-ScoopPackage {
    param([string]$Name)

    if (Test-CommandExists $Name) {
        Write-Status "$Name is already installed" -Type Success
        return $true
    }

    if (-not (Test-CommandExists 'scoop')) {
        Write-Status "Scoop not available, cannot install $Name" -Type Warning
        return $false
    }

    Write-Status "Installing $Name via scoop..." -Type Info
    try {
        scoop install $Name 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Status "$Name installed successfully" -Type Success
            return $true
        } else {
            Write-Status "Failed to install $Name via scoop" -Type Warning
            return $false
        }
    } catch {
        Write-Status "Error installing $Name via scoop: $_" -Type Error
        return $false
    }
}

# ============================================================================
# Header
# ============================================================================

Clear-Host
Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                               ║" -ForegroundColor Cyan
Write-Host "║             MyPowerShell Installer - Phase 2                  ║" -ForegroundColor Cyan
Write-Host "║     High-Performance PowerShell Environment for Windows       ║" -ForegroundColor Cyan
Write-Host "║                                                               ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# 1. Pre-flight Checks
# ============================================================================

Write-Status "Running pre-flight checks..." -Type Info

# Check PowerShell version
$psVersion = $PSVersionTable.PSVersion
if ($psVersion.Major -lt 5 -or ($psVersion.Major -eq 5 -and $psVersion.Minor -lt 1)) {
    Write-Status "PowerShell 5.1 or higher is required (you have $($psVersion))" -Type Error
    exit 1
}

if ($psVersion.Major -lt 7) {
    Write-Status "PowerShell $($psVersion) detected. PowerShell 7+ is recommended for better performance." -Type Warning
} else {
    Write-Status "PowerShell $($psVersion) detected" -Type Success
}

# Get script directory
$RepoDir = $PSScriptRoot
Write-Status "Repository directory: $RepoDir" -Type Info

# ============================================================================
# 2. Scoop Installation (Required for some tools)
# ============================================================================

Write-Host ""
Write-Status "Checking Scoop package manager..." -Type Info

if (-not (Test-CommandExists 'scoop')) {
    Write-Host ""
    if (Confirm "Scoop package manager is not installed. Install it now?") {
        try {
            Write-Status "Installing Scoop..." -Type Info

            # Set execution policy for current user
            Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue

            # Install Scoop
            Invoke-RestMethod get.scoop.sh | Invoke-Expression

            if (Test-CommandExists 'scoop') {
                Write-Status "Scoop installed successfully" -Type Success
            } else {
                Write-Status "Scoop installation may have failed. Some tools will be unavailable." -Type Warning
            }
        } catch {
            Write-Status "Failed to install Scoop: $_" -Type Error
            Write-Status "Continuing without Scoop. Some tools may not be available." -Type Warning
        }
    } else {
        Write-Status "Skipping Scoop installation. Some tools will be unavailable." -Type Warning
    }
} else {
    Write-Status "Scoop is already installed" -Type Success
}

# ============================================================================
# 3. Install Starship Prompt
# ============================================================================

Write-Host ""
Write-Status "Installing Starship prompt..." -Type Info

# Try winget first
$wingetSuccess = $false
if (Test-CommandExists 'winget') {
    $wingetSuccess = Install-WingetPackage -Id "Starship.Starship" -CommandName "starship"
}

# Fall back to scoop if winget failed
if (-not $wingetSuccess -and (Test-CommandExists 'scoop')) {
    Write-Status "Falling back to scoop for Starship installation..." -Type Info
    Install-ScoopPackage -Name "starship"
}

if (-not (Test-CommandExists 'starship')) {
    Write-Status "Failed to install Starship. Prompt customization will not be available." -Type Error
} else {
    Write-Status "Starship is ready" -Type Success
}

# ============================================================================
# 4. Install Tier 1 Tools (Core Navigation & File Tools)
# ============================================================================

Write-Host ""
Write-Status "Installing Tier 1 tools (navigation & file tools)..." -Type Info

# Track installation status
$toolsInstalled = @()
$toolsFailed = @()

# Define tools to install
$wingetTools = @(
    @{Id = "ajeetdsouza.zoxide"; Name = "zoxide"; Description = "Smart cd replacement" },
    @{Id = "junegunn.fzf"; Name = "fzf"; Description = "Fuzzy finder" },
    @{Id = "eza-community.eza"; Name = "eza"; Description = "Modern ls" },
    @{Id = "BurntSushi.ripgrep.MSVC"; Name = "rg"; Description = "Better grep" }
)

$scoopTools = @(
    @{Name = "bat"; Description = "Modern cat with syntax highlighting" },
    @{Name = "fd"; Description = "Better find" }
)

# Install via winget
if (Test-CommandExists 'winget') {
    Write-Host ""
    Write-Status "Installing tools via winget..." -Type Info
    foreach ($tool in $wingetTools) {
        if (Install-WingetPackage -Id $tool.Id -CommandName $tool.Name) {
            $toolsInstalled += $tool.Name
        } else {
            $toolsFailed += $tool.Name
            Write-Status "Will try scoop for $($tool.Name) if available" -Type Warning
        }
    }
} else {
    Write-Status "winget not available, will use scoop for all tools" -Type Warning
}

# Install via scoop (includes fallback for failed winget installs)
if (Test-CommandExists 'scoop') {
    Write-Host ""
    Write-Status "Installing tools via scoop..." -Type Info

    # Add tools from failed winget installs
    $allScoopTools = $scoopTools
    foreach ($failedTool in $toolsFailed) {
        $wingetTool = $wingetTools | Where-Object { $_.Name -eq $failedTool }
        if ($wingetTool -and $wingetTool.Name -in @('zoxide', 'fzf', 'eza', 'ripgrep')) {
            $scoopName = if ($failedTool -eq 'rg') { 'ripgrep' } else { $failedTool }
            $allScoopTools += @{Name = $scoopName; Description = $wingetTool.Description }
        }
    }

    foreach ($tool in $allScoopTools) {
        if (Install-ScoopPackage -Name $tool.Name) {
            $toolsInstalled += $tool.Name
        } else {
            Write-Status "Failed to install $($tool.Name)" -Type Warning
        }
    }
} else {
    Write-Status "Scoop not available, some tools could not be installed" -Type Warning
}

# ============================================================================
# 5. Install PowerShell Modules
# ============================================================================

Write-Host ""
Write-Status "Installing PowerShell modules..." -Type Info

$modules = @(
    @{Name = "PSFzf"; Description = "FZF integration for PowerShell (Ctrl+R, Ctrl+T)" }
)

foreach ($module in $modules) {
    if (Get-Module -ListAvailable -Name $module.Name) {
        Write-Status "$($module.Name) is already installed" -Type Success
    } else {
        Write-Status "Installing $($module.Name)..." -Type Info
        try {
            Install-Module $module.Name -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
            Write-Status "$($module.Name) installed successfully" -Type Success
        } catch {
            Write-Status "Failed to install $($module.Name): $_" -Type Warning
        }
    }
}

# ============================================================================
# 6. Deploy Configuration Files
# ============================================================================

Write-Host ""
Write-Status "Deploying configuration files..." -Type Info

# Create .config directory if it doesn't exist
$configDir = "$env:USERPROFILE\.config"
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    Write-Status "Created $configDir" -Type Success
}

# Copy starship.toml (overwrite if exists)
$starshipSource = Join-Path $RepoDir "configs\starship.toml"
$starshipDest = Join-Path $configDir "starship.toml"

Copy-Item $starshipSource $starshipDest -Force
Write-Status "Starship config deployed to $starshipDest" -Type Success

# ============================================================================
# 7. Setup PowerShell Profile
# ============================================================================

Write-Host ""
Write-Status "Setting up PowerShell profile..." -Type Info

# Ensure $PROFILE exists
if (-not (Test-Path $PROFILE)) {
    $profileDir = Split-Path $PROFILE -Parent
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    Write-Status "Created new profile at $PROFILE" -Type Success
}

# Add hook to source our profile
$profileSource = Join-Path $RepoDir "scripts\profile.ps1"
$hookLine = ". `"$profileSource`""

$existingContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($existingContent -notlike "*$profileSource*") {
    $hookComment = @"

# ============================================================================
# MyPowerShell Configuration
# ============================================================================
$hookLine
"@
    Add-Content -Path $PROFILE -Value $hookComment
    Write-Status "Added MyPowerShell hook to profile" -Type Success
} else {
    Write-Status "MyPowerShell hook already exists in profile" -Type Info
}

# ============================================================================
# 8. Installation Complete
# ============================================================================

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                               ║" -ForegroundColor Green
Write-Host "║                  Installation Complete! ✓                     ║" -ForegroundColor Green
Write-Host "║                                                               ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

Write-Status "Phase 2 (Core Tools) installation complete!" -Type Success
Write-Host ""
Write-Host "What was installed:" -ForegroundColor Cyan
Write-Host "  • Starship prompt with Tokyo Night theme" -ForegroundColor Gray
Write-Host "  • Enhanced PSReadLine (history & predictions)" -ForegroundColor Gray
Write-Host "  • zoxide - Smart directory navigation (z/zi)" -ForegroundColor Gray
Write-Host "  • fzf + PSFzf - Fuzzy finder (Ctrl+R, Ctrl+T)" -ForegroundColor Gray
Write-Host "  • eza - Modern ls with icons (ls/ll/la/lt)" -ForegroundColor Gray
Write-Host "  • bat - Syntax-highlighted cat" -ForegroundColor Gray
Write-Host "  • fd - Fast file finder" -ForegroundColor Gray
Write-Host "  • ripgrep - Fast grep (rg)" -ForegroundColor Gray
Write-Host ""
Write-Host "Quick Start:" -ForegroundColor Cyan
Write-Host "  z <dir>       - Jump to frequently used directories" -ForegroundColor Gray
Write-Host "  zi            - Interactive directory picker" -ForegroundColor Gray
Write-Host "  ls/ll/la      - Beautiful file listings with icons" -ForegroundColor Gray
Write-Host "  Ctrl+R        - Fuzzy search command history" -ForegroundColor Gray
Write-Host "  Ctrl+T        - Fuzzy find files" -ForegroundColor Gray
Write-Host "  cat <file>    - View files with syntax highlighting" -ForegroundColor Gray
Write-Host "  fd <pattern>  - Fast file search" -ForegroundColor Gray
Write-Host "  rg <pattern>  - Fast text search" -ForegroundColor Gray
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Restart your terminal or run: " -ForegroundColor Gray -NoNewline
Write-Host ". `$PROFILE" -ForegroundColor Yellow
Write-Host "  2. For full icon support, install a Nerd Font:" -ForegroundColor Gray
Write-Host "     JetBrainsMono Nerd Font from https://www.nerdfonts.com/" -ForegroundColor Gray
Write-Host ""
Write-Host "Coming in Phase 3:" -ForegroundColor Cyan
Write-Host "  • Development tools (lazygit, delta, dust)" -ForegroundColor Gray
Write-Host "  • Windows Terminal Tokyo Night theme" -ForegroundColor Gray
Write-Host "  • Terminal-Icons module" -ForegroundColor Gray
Write-Host ""
Write-Host "Profile location: $PROFILE" -ForegroundColor DarkGray
Write-Host ""
