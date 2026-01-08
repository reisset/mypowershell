# MyPowerShell - Project Specification

## Project Overview

**MyPowerShell** is a high-performance, opinionated PowerShell environment configuration for Windows 10/11. It mirrors the philosophy and user experience of [MyBash](https://github.com/reisset/mybash) - promoting learning of standard PowerShell commands while adding modern CLI tools as supplementary superpowers.

---

## Terminal vs Shell: Critical Distinction

**This project configures a SHELL (PowerShell), not a terminal emulator.**

| Concept | What It Is | MyBash | MyPowerShell |
|---------|------------|--------|--------------|
| **Shell** | The command interpreter/language | bash | PowerShell |
| **Terminal Emulator** | The window application that displays the shell | Kitty | Windows Terminal |

```
┌─────────────────────────────────────────┐
│  Windows Terminal (terminal emulator)   │  ← The window/app
│  ┌───────────────────────────────────┐  │
│  │  PowerShell 7.x (shell)           │  │  ← The language
│  │  + Starship prompt                │  │
│  │  + zoxide, fzf, eza, bat, etc.    │  │
│  │  + Our aliases and config         │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### Windows Shell Options (Use PowerShell)

| Shell | Description | Recommendation |
|-------|-------------|----------------|
| **Command Prompt (cmd.exe)** | Legacy DOS shell | ❌ Skip - too limited, no modern tooling |
| **Windows PowerShell 5.1** | Built-in (blue icon), ships with Windows | ✅ Works fine |
| **PowerShell 7+ (pwsh.exe)** | Newer cross-platform version (black icon) | ✅ Recommended if installed |

The installer will work with either PowerShell 5.1 or 7+. Most Windows 11 users launching "Terminal" get PowerShell 7.x automatically.

### Terminal Emulator (Use Windows Terminal)

| Terminal | Description | Recommendation |
|----------|-------------|----------------|
| **Windows Terminal** | Microsoft's modern GPU-accelerated terminal | ✅ **Recommended** |
| **Kitty** | Linux-first terminal (works on Windows) | ⚠️ Works but less native |
| **Alacritty** | Cross-platform GPU terminal | ⚠️ Works but less integrated |
| **ConHost (legacy)** | Old Windows console host | ❌ Skip - outdated |

**Why Windows Terminal over Kitty on Windows:**
- GPU-accelerated with tabs, splits, and panes (same features as Kitty)
- Ships with Windows 11; easy winget install on Windows 10
- Perfect Nerd Font rendering
- Native OS integration (right-click → "Open in Terminal", File Explorer integration)
- Theming via JSON (Tokyo Night works perfectly)
- Actively maintained by Microsoft specifically for Windows

Kitty *can* run on Windows, but it's Linux-first. You'd fight against the grain for minimal benefit.

### Core Philosophy: Learning-First

- **Standard commands preserved**: `cd`, `Get-ChildItem`, `Get-Process`, `Get-Content` remain untouched
- **Modern tools as supplements**: Added as separate commands (e.g., `z`, `dust`, `fd`) not replacements
- **Muscle memory compatible**: Skills transfer to vanilla Windows systems without these tools
- **Fast, beautiful, minimal**: Sub-second prompt rendering, Tokyo Night theme, no bloat

### Target Audience

- Windows power users who want a modern terminal experience
- Linux users who need to work on Windows
- Users who want easy deployment across multiple Windows machines

### Non-Goals

- No WSL integration or Linux tooling
- No server/headless configurations
- No replacement of standard PowerShell commands by default

---

## Architecture

```
mypowershell/
├── install.ps1              # Main installer script
├── configs/
│   ├── starship.toml        # Starship prompt configuration (Tokyo Night)
│   ├── windows-terminal.json # Windows Terminal settings fragment
│   └── delta.gitconfig      # Git delta configuration
├── scripts/
│   ├── profile.ps1          # Main PowerShell profile
│   ├── aliases.ps1          # Tool aliases and functions
│   └── completions.ps1      # Tab completions for tools
├── docs/
│   └── TOOLS.md             # Quick reference guide (mirrors mybash)
├── README.md
├── LICENSE                  # MIT
└── SECURITY.md
```

---

## Tool Selection

### Tier 1: Core Experience (Always Installed)

| Tool | Purpose | Installation Method | MyBash Equivalent |
|------|---------|---------------------|-------------------|
| **Starship** | Prompt | winget | ✓ Same |
| **zoxide** | Smart cd | winget | ✓ Same |
| **fzf** | Fuzzy finder | winget | ✓ Same |
| **bat** | Better cat | scoop | ✓ Same |
| **eza** | Better ls | winget | ✓ Same |
| **fd** | Better find | scoop | ✓ Same |
| **ripgrep** | Better grep | winget | ✓ Same |

### Tier 2: Development Tools (Always Installed)

| Tool | Purpose | Installation Method | MyBash Equivalent |
|------|---------|---------------------|-------------------|
| **lazygit** | Git TUI | winget | ✓ Same |
| **delta** | Git diffs | scoop | ✓ Same |
| **dust** | Disk usage | scoop | ✓ Same |

### Tier 3: Optional/Prompted

| Tool | Purpose | Condition |
|------|---------|-----------|
| **yazi** | File manager | User confirms |
| **tealdeer (tldr)** | Man pages | User confirms |

### Excluded from MyBash (Not Applicable to Desktop Windows)

- btop, nvtop, bandwhich (system monitoring - not needed per user)
- procs (Windows has different process model)
- hyperfine, tokei (dev benchmarking - optional stretch goal)

---

## Installation Strategy

### Package Manager Priority

1. **winget** (preferred) - Built into Windows 11, available on Windows 10
2. **Scoop** (fallback) - For tools not in winget, or when winget unavailable

### Installation Flow

```
1.  Check PowerShell version (require 5.1+, recommend 7+)
2.  Check/offer Windows Terminal installation (if not present)
3.  Check/install Scoop (required for some tools)
4.  Install tools via winget (Starship, zoxide, fzf, eza, rg, lazygit)
5.  Install tools via Scoop (bat, fd, delta, dust)
6.  Install PowerShell modules (PSReadLine, PSFzf, Terminal-Icons)
7.  Install Nerd Font (user choice: JetBrainsMono or CaskaydiaCove)
8.  Link/create configuration files (starship.toml)
9.  Configure Windows Terminal theme (Tokyo Night, if WT present)
10. Add profile hook to $PROFILE
11. Configure git to use delta (optional, prompted)
12. Optional tools (Yazi, tealdeer)
```

**Comparison to MyBash:**
| Step | MyBash | MyPowerShell |
|------|--------|--------------|
| Terminal setup | Kitty (installed by script) | Windows Terminal (usually pre-installed) |
| Package manager | apt + GitHub releases | winget + Scoop |
| Shell config | ~/.bashrc | $PROFILE |
| Config location | ~/.config/ | $env:USERPROFILE\.config\ |

### No Admin Required

The entire installation should work without administrator privileges:
- Scoop installs to `~\scoop\`
- winget user-scope installations
- Configs go to standard user locations

---

## Configuration Details

### PowerShell Profile (`scripts/profile.ps1`)

```powershell
# MyPowerShell Profile
# Sources modular configuration files

$MyPowerShellRoot = "PATH_TO_REPO"  # Set by installer

# 1. Source Aliases
. "$MyPowerShellRoot\scripts\aliases.ps1"

# 2. Starship Prompt
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# 3. Zoxide
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# 4. FZF + PSFzf
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    Import-Module PSFzf -ErrorAction SilentlyContinue
    Set-PsFzfOption -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t'
}

# 5. PSReadLine Enhancements
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -BellStyle None

# 6. Terminal Icons (if installed)
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons
}

# 7. Yazi wrapper (cd on exit)
function y {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -ErrorAction SilentlyContinue
    if ($cwd -and $cwd -ne $PWD.Path) {
        Set-Location -Path $cwd
    }
    Remove-Item -Path $tmp -ErrorAction SilentlyContinue
}

# 8. Auto-ls on directory change (optional - can be slow)
# Uncomment if desired:
# function Set-LocationWithList {
#     param([string]$Path)
#     Set-Location $Path
#     eza --icons
# }
# Set-Alias -Name cd -Value Set-LocationWithList -Option AllScope

# 9. Welcome Message (first shell only)
if (-not $env:MYPOWERSHELL_WELCOMED) {
    Write-Host "📚 MyPowerShell - Learning Mode Active" -ForegroundColor Cyan
    Write-Host "New tools: z/zi, tldr, dust, fd, lg, delta" -ForegroundColor DarkGray
    Write-Host "Standard commands (cd, dir, Get-Process) still work! Type 'tools' for reference." -ForegroundColor DarkGray
    $env:MYPOWERSHELL_WELCOMED = "1"
}
```

### Aliases (`scripts/aliases.ps1`)

```powershell
# scripts/aliases.ps1

# ==============================================================================
# MODERN TOOL ALIASES (Learning-First)
# These ADD new commands, they don't replace standards
# ==============================================================================

# Eza (modern ls) - with glob workaround
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ls { eza --icons $args }
    function ll { eza -al --icons --group-directories-first $args }
    function la { eza -a --icons --group-directories-first $args }
    function lt { eza --tree --level=2 --icons $args }
    
    # Glob workaround: lsg "*.txt" expands properly
    function lsg {
        param([string]$Pattern = "*")
        Get-ChildItem -Name $Pattern | ForEach-Object { eza --icons $_ }
    }
}

# Bat (modern cat)
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Set-Alias -Name cat -Value bat -Option AllScope
    # Keep Get-Content available as 'gc' (PowerShell default)
}

# Ripgrep
if (Get-Command rg -ErrorAction SilentlyContinue) {
    Set-Alias -Name grep -Value rg -Option AllScope
    # Select-String still available as 'sls'
}

# Fd
if (Get-Command fd -ErrorAction SilentlyContinue) {
    Set-Alias -Name find -Value fd -Option AllScope
    # Get-ChildItem -Recurse still works
}

# Navigation
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    function zi { z -i $args }  # Interactive zoxide
}

# Git shortcuts
Set-Alias -Name g -Value git
function gs { git status }
function ga { git add $args }
function gc { git commit $args }
function gp { git push $args }
function gl { git pull $args }

# Development
if (Get-Command lazygit -ErrorAction SilentlyContinue) {
    Set-Alias -Name lg -Value lazygit
}

# Disk usage
if (Get-Command dust -ErrorAction SilentlyContinue) {
    # dust is already the command, no alias needed
    # Standard: Get-PSDrive, or explorer properties
}

# Quick Reference
function tools {
    $toolsPath = Join-Path $MyPowerShellRoot "docs\TOOLS.md"
    if (Get-Command bat -ErrorAction SilentlyContinue) {
        bat $toolsPath
    } elseif (Get-Command glow -ErrorAction SilentlyContinue) {
        glow $toolsPath
    } else {
        Get-Content $toolsPath
    }
}

# ==============================================================================
# OPTIONAL: POWER MODE (Uncomment to fully replace standard commands)
# WARNING: This breaks muscle memory for vanilla Windows systems
# ==============================================================================
# Remove-Alias -Name cd -Force -ErrorAction SilentlyContinue
# Set-Alias -Name cd -Value z -Option AllScope
# ==============================================================================
```

### Starship Config (`configs/starship.toml`)

**Use the exact same file from MyBash** (`configs/starship_text.toml`). Starship configs are cross-platform. Only change needed:

```toml
# Add Windows-specific OS symbol if os module enabled
[os.symbols]
Windows = "󰍲 "
```

### Windows Terminal Settings Fragment (`configs/windows-terminal.json`)

```json
{
    "profiles": {
        "defaults": {
            "font": {
                "face": "JetBrainsMono Nerd Font",
                "size": 12
            },
            "colorScheme": "Tokyo Night",
            "padding": "10"
        }
    },
    "schemes": [
        {
            "name": "Tokyo Night",
            "background": "#1A1B26",
            "foreground": "#C0CAF5",
            "selectionBackground": "#33467C",
            "cursorColor": "#C0CAF5",
            "black": "#15161E",
            "red": "#F7768E",
            "green": "#9ECE6A",
            "yellow": "#E0AF68",
            "blue": "#7AA2F7",
            "purple": "#BB9AF7",
            "cyan": "#7DCFFF",
            "white": "#A9B1D6",
            "brightBlack": "#414868",
            "brightRed": "#F7768E",
            "brightGreen": "#9ECE6A",
            "brightYellow": "#E0AF68",
            "brightBlue": "#7AA2F7",
            "brightPurple": "#BB9AF7",
            "brightCyan": "#7DCFFF",
            "brightWhite": "#C0CAF5"
        }
    ]
}
```

### Delta Git Config (`configs/delta.gitconfig`)

**Use the exact same file from MyBash** - delta configuration is cross-platform.

---

## Installer Script (`install.ps1`)

### Requirements

- **Terminal Emulator**: Windows Terminal (recommended, auto-detected)
- **Shell**: PowerShell 5.1+ (built-in) or PowerShell 7+ (recommended)
- Internet connection
- No administrator privileges required

### Pre-flight Checks

```powershell
# 1. Verify PowerShell version
$PSVersionTable.PSVersion  # Require >= 5.1, recommend >= 7.0

# 2. Check for Windows Terminal (optional but recommended)
$wtInstalled = Get-Command wt.exe -ErrorAction SilentlyContinue
if (-not $wtInstalled) {
    Write-Host "Windows Terminal not found. Install via: winget install Microsoft.WindowsTerminal" -ForegroundColor Yellow
    Write-Host "You can continue, but Windows Terminal is recommended for the best experience." -ForegroundColor Yellow
}
```

### Installer Behavior

```powershell
# Pseudocode structure

# 1. Header and version check
Write-Host "MyPowerShell Installer v1.0"
Check-PowerShellVersion  # Warn if < 7, require >= 5.1

# 2. Windows Terminal check/install
if (-not (Get-Command wt.exe -ErrorAction SilentlyContinue)) {
    Write-Host "Windows Terminal not detected." -ForegroundColor Yellow
    if (Confirm "Install Windows Terminal? (Highly recommended)") {
        winget install Microsoft.WindowsTerminal --accept-source-agreements --accept-package-agreements
    } else {
        Write-Host "Continuing without Windows Terminal. Config will work in any PowerShell host." -ForegroundColor Yellow
    }
}

# 3. Scoop installation (required for some tools)
if (-not (Get-Command scoop)) {
    if (Confirm "Install Scoop package manager?") {
        # Install Scoop (no admin needed)
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod get.scoop.sh | Invoke-Expression
    }
}

# 4. Install tools via winget (preferred)
$wingetTools = @(
    @{Name="Starship.Starship"; Cmd="starship"},
    @{Name="ajeetdsouza.zoxide"; Cmd="zoxide"},
    @{Name="junegunn.fzf"; Cmd="fzf"},
    @{Name="eza-community.eza"; Cmd="eza"},
    @{Name="BurntSushi.ripgrep.MSVC"; Cmd="rg"},
    @{Name="JesseDuffield.Lazygit"; Cmd="lazygit"}
)

foreach ($tool in $wingetTools) {
    if (-not (Get-Command $tool.Cmd -ErrorAction SilentlyContinue)) {
        winget install --id $tool.Name --accept-source-agreements --accept-package-agreements
    }
}

# 5. Install tools via Scoop (fallback or scoop-only)
$scoopTools = @("bat", "fd", "delta", "dust")
foreach ($tool in $scoopTools) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        scoop install $tool
    }
}

# 6. Install PowerShell modules
$modules = @("PSReadLine", "PSFzf", "Terminal-Icons")
foreach ($mod in $modules) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Install-Module $mod -Scope CurrentUser -Force -AllowClobber
    }
}

# 7. Nerd Font installation
if (Confirm "Install JetBrainsMono Nerd Font?") {
    # Use oh-my-posh font installer or scoop
    scoop bucket add nerd-fonts
    scoop install JetBrainsMono-NF
}

# 8. Link configurations
$configDir = "$env:USERPROFILE\.config"
New-Item -ItemType Directory -Path $configDir -Force
Copy-Item "$RepoDir\configs\starship.toml" "$configDir\starship.toml" -Force

# 9. Windows Terminal configuration (if installed)
$wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_*\LocalState\settings.json"
if (Test-Path $wtSettingsPath) {
    if (Confirm "Add Tokyo Night theme to Windows Terminal?") {
        # Merge color scheme into existing settings
        Add-TokyoNightTheme $wtSettingsPath
    }
}

# 10. Profile hook
$profileLine = ". `"$RepoDir\scripts\profile.ps1`""
if (-not (Select-String -Path $PROFILE -Pattern "mypowershell" -Quiet -ErrorAction SilentlyContinue)) {
    Add-Content -Path $PROFILE -Value "`n# MyPowerShell`n$profileLine"
}

# 11. Delta git configuration (optional)
if (Confirm-No "Configure git to use delta for diffs?") {
    git config --global include.path "$RepoDir\configs\delta.gitconfig"
}

# 12. Optional tools
if (Confirm-No "Install Yazi file manager?") {
    scoop install yazi
}
if (Confirm-No "Install tealdeer (tldr)?") {
    scoop install tealdeer
}

Write-Host "Installation complete! Restart your terminal." -ForegroundColor Green
```

---

## TOOLS.md Quick Reference

```markdown
# 📚 MyPowerShell - Modern CLI Tools Guide

## 🧠 Philosophy: Learning-First
MyPowerShell adds powerful modern tools but **does not replace** the originals.
- `cd`, `dir`, `Get-Process`, `Get-Content` work exactly as standard PowerShell
- Modern tools are provided as **separate commands** (e.g., `z`, `dust`, `fd`)
- Your muscle memory remains compatible with vanilla Windows systems

---

## 🛠️ Tool Reference

### Navigation & Search
| Modern Tool | Command | Standard Equivalent | Why use it? |
|-------------|---------|---------------------|-------------|
| **zoxide** | `z`, `zi` | `cd` | Jumps to frequent directories by name |
| **fd** | `fd` | `Get-ChildItem -Recurse` | Much faster, simpler syntax |
| **fzf** | `Ctrl+t`, `Ctrl+r` | - | Fuzzy finder with previews |
| **ripgrep** | `rg` | `Select-String` | Blazingly fast, respects .gitignore |

### File Viewing
| Modern Tool | Command | Standard Equivalent | Why use it? |
|-------------|---------|---------------------|-------------|
| **eza** | `ls`, `ll`, `la`, `lt` | `dir`, `Get-ChildItem` | Icons, colors, tree view |
| **bat** | `cat` | `Get-Content` | Syntax highlighting, git integration |
| **yazi** | `y` | Explorer | Terminal file manager with previews |

### Development
| Modern Tool | Command | Description |
|-------------|---------|-------------|
| **lazygit** | `lg` | TUI for git - staging, commits, branches |
| **delta** | `git diff` | Beautiful syntax-highlighted diffs |
| **dust** | `dust` | Visual disk usage tree |
| **tealdeer** | `tldr` | Practical command examples |

---

## ⌨️ Quick Shortcuts
- `tools` - Show this guide
- `lg` - Open LazyGit
- `zi` - Interactive directory jumper
- `Ctrl+r` - Fuzzy search command history
- `Ctrl+t` - Fuzzy find files
- `tldr <cmd>` - Quick help for any command

---

## ⚠️ Eza Glob Workaround
Windows doesn't expand wildcards like Linux. Use `lsg` for glob patterns:
```powershell
lsg "*.txt"      # Works! Lists all .txt files with eza
eza *.txt        # Fails on Windows (os error 123)
```

---

## 🚀 Power Mode (Optional)
See `scripts\aliases.ps1` for a commented "Power Mode" section that fully
replaces standard commands. **Warning:** Breaks muscle memory for vanilla systems!
```

---

## Security Considerations

### Installation Security

1. **No piping to Invoke-Expression from URLs** - Download scripts first, then execute
2. **Scoop installation** - Uses official documented method
3. **winget** - Microsoft's official package manager, signed packages
4. **No admin required** - Everything installs to user space

### Script Execution Policy

The installer will need to set execution policy for the current user:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

This is the minimum required and is documented in README.

### Verification Steps

- All winget packages are from verified publishers
- Scoop packages come from official buckets
- No external URLs beyond package managers

---

## Files to Reuse from MyBash

These files can be copied with minimal or no changes:

| MyBash File | MyPowerShell File | Changes Needed |
|-------------|-------------------|----------------|
| `configs/starship_text.toml` | `configs/starship.toml` | Add Windows OS symbol |
| `configs/delta.gitconfig` | `configs/delta.gitconfig` | None |
| `LICENSE` | `LICENSE` | None |
| `docs/TOOLS.md` | `docs/TOOLS.md` | Adapt commands for PowerShell |

---

## Testing Checklist

### Fresh Install Test
- [ ] Clone repo on clean Windows 10/11 machine
- [ ] Run `install.ps1` without admin
- [ ] Verify all tools installed and accessible
- [ ] Verify prompt appears correctly (Starship)
- [ ] Verify Tokyo Night theme in Windows Terminal

### Tool Functionality
- [ ] `z` learns directories after cd'ing around
- [ ] `zi` shows interactive picker
- [ ] `Ctrl+r` fuzzy searches history
- [ ] `Ctrl+t` fuzzy finds files
- [ ] `ls`, `ll`, `la`, `lt` show icons correctly
- [ ] `cat` shows syntax highlighting
- [ ] `rg` searches files quickly
- [ ] `fd` finds files
- [ ] `lg` opens lazygit
- [ ] `git diff` shows delta formatting
- [ ] `dust` shows disk usage
- [ ] `y` opens yazi and changes dir on exit
- [ ] `tools` displays the quick reference

### Edge Cases
- [ ] Works without Windows Terminal (plain PowerShell window)
- [ ] Works with PowerShell 5.1 (not just 7)
- [ ] Doesn't break if a tool fails to install
- [ ] Profile loads quickly (< 500ms target)

---

## Performance Targets

| Metric | Target | MyBash Equivalent |
|--------|--------|-------------------|
| Profile load time | < 500ms | Same |
| Prompt render | < 50ms | Same (Starship) |
| First `z` lookup | < 100ms | Same |
| `ls` on large dir | < 200ms | Same (eza) |

### Performance Optimizations

1. **Lazy-load modules** - Only import when first used if possible
2. **Skip welcome message** - After first shell in session
3. **Conditional tool init** - Only init tools that exist
4. **No auto-ls on cd** - Disabled by default (optional uncomment)

---

## Version Roadmap

### v1.0 (Initial Release)
- Core tool installation (Starship, zoxide, fzf, eza, bat, fd, rg, delta, lazygit, dust)
- Tokyo Night theme
- Windows Terminal integration
- Full documentation

### v1.1 (Polish)
- Yazi file manager support
- tealdeer integration
- Profile load time optimizations
- Better error handling in installer

### Future Considerations
- Backup existing $PROFILE before modifying
- Uninstall script
- Update script (refresh tools)
- Theme variants (Catppuccin, Dracula)

---

## Implementation Notes for Coding Agent

### Key Differences from MyBash

1. **Package managers**: `apt` → `winget` + `scoop` (not one-liner installs)
2. **Shell syntax**: Bash → PowerShell (very different!)
3. **Paths**: `/home/user` → `$env:USERPROFILE`, forward slash → backslash
4. **Config location**: `~/.config/` → `$env:USERPROFILE\.config\`
5. **Profile**: `~/.bashrc` → `$PROFILE` (usually `Documents\PowerShell\Microsoft.PowerShell_profile.ps1`)
6. **Aliases**: `alias x='y'` → `Set-Alias -Name x -Value y` or functions
7. **Command check**: `command -v` → `Get-Command -ErrorAction SilentlyContinue`
8. **Sourcing**: `source file.sh` → `. file.ps1`

### Critical Implementation Details

1. **eza glob workaround** - Must implement `lsg` function since `eza *.txt` fails on Windows
2. **PSFzf module** - Required for Ctrl+r and Ctrl+t bindings (not built into fzf on Windows)
3. **Terminal-Icons** - Required for icons in PowerShell (eza icons work, but `Get-ChildItem` needs this)
4. **Nerd Font** - Absolutely required, installer should make this very clear
5. **$PROFILE creation** - May not exist on fresh systems, create parent directory if needed

### Installer Must Handle

1. `$PROFILE` file and parent directory may not exist
2. Windows Terminal may not be installed (should still work in plain PowerShell)
3. winget may not be available on older Windows 10 (fall back to scoop-only)
4. Scoop bucket `nerd-fonts` needs to be added before font install
5. Some tools need `scoop install git` first (for PATH and other dependencies)

### File Encoding

All PowerShell scripts should be UTF-8 with BOM for maximum compatibility with PowerShell 5.1.

---

## Reference Links

- [Starship PowerShell setup](https://starship.rs/guide/#powershell)
- [Scoop installer](https://scoop.sh/)
- [PSFzf module](https://github.com/kelleyma49/PSFzf)
- [Terminal-Icons](https://github.com/devblackops/Terminal-Icons)
- [Windows Terminal themes](https://windowsterminalthemes.dev/)
- [zoxide PowerShell](https://github.com/ajeetdsouza/zoxide#powershell)
