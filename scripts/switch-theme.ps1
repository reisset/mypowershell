#Requires -Version 5.1
<#
.SYNOPSIS
    MyPowerShell Theme Switcher
.DESCRIPTION
    Switches between "tokyo" (Tokyo Night) and "htb" (Hack The Box) themes.
    Updates both starship.toml and Windows Terminal colorScheme without reinstalling.
.PARAMETER Theme
    The theme to activate: "htb" or "tokyo"
.EXAMPLE
    theme htb
    theme tokyo
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("htb", "tokyo", "matrix", "kanagawa")]
    [string]$Theme
)

function Write-Status {
    param([string]$Message, [ValidateSet('Info', 'Success', 'Warning', 'Error')][string]$Type = 'Info')
    $color  = switch ($Type) { 'Info' { 'Cyan' } 'Success' { 'Green' } 'Warning' { 'Yellow' } 'Error' { 'Red' } }
    $prefix = switch ($Type) { 'Info' { '[*]' }  'Success' { '[+]' }   'Warning' { '[!]' }    'Error' { '[x]' } }
    Write-Host "$prefix $Message" -ForegroundColor $color
}

$RepoDir  = $PSScriptRoot | Split-Path -Parent
$themeMap = @{
    "htb"      = @{ StarshipSrc = "starship-htb.toml";      SchemeName = "Hack The Box" }
    "tokyo"    = @{ StarshipSrc = "starship.toml";           SchemeName = "Tokyo Night"  }
    "matrix"   = @{ StarshipSrc = "starship-matrix.toml";   SchemeName = "Matrix"       }
    "kanagawa" = @{ StarshipSrc = "starship-kanagawa.toml"; SchemeName = "Kanagawa"     }
}
$selected     = $themeMap[$Theme]
$starshipSrc  = Join-Path $RepoDir "configs\$($selected.StarshipSrc)"
$starshipDest = "$env:USERPROFILE\.config\starship.toml"
$schemeName   = $selected.SchemeName

Write-Status "Activating $schemeName theme..." -Type Info

# ============================================================================
# Step 1: Deploy Starship config
# ============================================================================

if (-not [System.IO.File]::Exists($starshipSrc)) {
    Write-Status "Source config not found: $starshipSrc" -Type Error
    exit 1
}

try {
    $configDir = "$env:USERPROFILE\.config"
    if (-not [System.IO.Directory]::Exists($configDir)) {
        [System.IO.Directory]::CreateDirectory($configDir) | Out-Null
    }
    [System.IO.File]::Copy($starshipSrc, $starshipDest, $true)
    Write-Status "Starship config deployed" -Type Success
} catch {
    Write-Status "Failed to deploy Starship config: $_" -Type Error
    exit 1
}

# ============================================================================
# Step 2: Update Windows Terminal colorScheme
# ============================================================================

$wtSettingsPath = Get-ChildItem "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_*\LocalState\settings.json" `
    -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $wtSettingsPath) {
    Write-Status "Windows Terminal settings not found. Starship updated; WT unchanged." -Type Warning
} else {
    try {
        $wtSettings = Get-Content $wtSettingsPath.FullName -Raw | ConvertFrom-Json

        # Sync the scheme from repo (picks up any color changes)
        $repoConfig = Get-Content (Join-Path $RepoDir "configs\windows-terminal.json") -Raw | ConvertFrom-Json
        $repoScheme = $repoConfig.schemes | Where-Object { $_.name -eq $schemeName }
        if ($repoScheme) {
            if (-not $wtSettings.schemes) {
                $wtSettings | Add-Member -MemberType NoteProperty -Name "schemes" -Value @() -Force
            }
            $wtSettings.schemes = @($wtSettings.schemes | Where-Object { $_.name -ne $schemeName }) + $repoScheme
        }

        if (-not ($wtSettings.schemes | Where-Object { $_.name -eq $schemeName })) {
            Write-Status "Scheme '$schemeName' not registered. Run install.ps1 first." -Type Warning
        } else {
            if (-not $wtSettings.profiles.defaults) {
                $wtSettings.profiles | Add-Member -MemberType NoteProperty -Name "defaults" -Value ([PSCustomObject]@{}) -Force
            }
            $wtSettings.profiles.defaults | Add-Member -MemberType NoteProperty -Name "colorScheme" -Value $schemeName -Force
            $wtSettings | ConvertTo-Json -Depth 10 | Set-Content $wtSettingsPath.FullName -Force
            Write-Status "Windows Terminal colorScheme set to '$schemeName'" -Type Success
        }
    } catch {
        Write-Status "Failed to update WT settings: $_" -Type Error
    }
}

# ============================================================================
# Step 3: Clear Starship init cache (cosmetic - ensures clean state)
# ============================================================================

$starshipCache = "$env:TEMP\mypowershell-starship-init.ps1"
if ([System.IO.File]::Exists($starshipCache)) {
    try { [System.IO.File]::Delete($starshipCache) } catch { }
}

# ============================================================================
# Done
# ============================================================================

Write-Host ""
Write-Host "Theme switched to: " -NoNewline -ForegroundColor White
$themeColor = switch ($Theme) {
    "htb"      { "Green" }
    "matrix"   { "Green" }
    "kanagawa" { "Yellow" }
    default    { "Cyan" }
}
Write-Host $schemeName -ForegroundColor $themeColor
Write-Host "Reload profile:   " -NoNewline -ForegroundColor Gray
Write-Host ". `$PROFILE" -ForegroundColor Yellow
Write-Host "Open new WT tab to see color scheme change." -ForegroundColor Gray
Write-Host ""
