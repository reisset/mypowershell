# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Project Overview

**MyPowerShell** is a high-performance PowerShell environment for Windows 11. It enhances the PowerShell experience with modern CLI tools while preserving muscle memory for standard commands.

**Version**: v2.2.0
**Repository**: https://github.com/reisset/mypowershell
**License**: MIT

## Philosophy

- **Learning-First**: Modern tools enhance PowerShell, but standard commands remain untouched
- **Performance**: ~28-32ms warm profile load time (optimized through v2.0.1)
- **Pragmatic Error Handling**: Warns on errors but continues installation
- **No Admin Required**: All tools install to user directories via Scoop/winget
- **Muscle Memory Safe**: Works on vanilla systems - you won't get lost

## File Structure

```
mypowershell/
├── install.ps1                  # Main installer (winget/scoop)
├── uninstall.ps1                # Comprehensive uninstaller
├── scripts/
│   ├── profile.ps1             # Main profile (starship, zoxide, fzf)
│   ├── aliases.ps1             # Tool aliases (eza, bat, fd, rg) + theme switcher
│   └── switch-theme.ps1        # Theme switcher (deploys starship + updates WT scheme)
├── configs/
│   ├── starship.toml           # Starship prompt config (Tokyo Night)
│   ├── starship-htb.toml       # Starship prompt config (Hack The Box)
│   ├── starship-matrix.toml    # Starship prompt config (Matrix)
│   ├── starship-kanagawa.toml  # Starship prompt config (Kanagawa)
│   └── windows-terminal.json   # WT theme fragment (all 4 schemes + JetBrainsMono 15pt)
├── docs/
│   └── TOOLS.md                # Quick reference guide
├── README.md                   # User documentation
├── SECURITY.md                 # Security policy
├── CHANGELOG.md                # Version history
├── LICENSE                     # MIT License
└── CLAUDE.md                   # This file
```

## Tools Installed

### Core Tools
- **Starship**: Fast, git-aware prompt (minimal config)
- **zoxide**: Smart directory navigation (`z`, `zi`)
- **fzf + PSFzf**: Fuzzy finder (Ctrl+R for history, Ctrl+T for files)
- **eza**: Modern ls with icons (`ls`, `ll`, `la`, `lt`)
- **bat**: Syntax-highlighted cat
- **fd**: Fast file finder (aliased to `find`)
- **ripgrep**: Fast text search (`rg`, aliased to `grep`)

### Optional Tools
- **yazi**: Terminal file manager (`y`)

### Visual Enhancements
- **JetBrainsMono Nerd Font**: Installed via scoop nerd-fonts bucket
- **Five Themes**: tokyo, htb, matrix, kanagawa, ubuntu — all registered in Windows Terminal on install
- **OS Icon**: Windows Nerd Font glyph in prompt (`󰍲`, nf-md-windows)

## Key Design Decisions

1. **No Terminal-Icons module**: Removed due to ~450ms startup penalty
2. **Font Size**: 15pt (user preference, 12pt was too small)
3. **PSFzf Lazy-Loading**: Module loads only when Ctrl+R or Ctrl+T pressed
4. **Config Overwrites**: Automatic without prompting (for repeatability)
5. **Yazi Wrapper**: Allows directory changes after exiting file manager
6. **Deployed Config**: Starship reads from `~\.config\starship.toml`, not the repo copy
7. **Multi-Theme System**: Five themes (tokyo/htb/matrix/kanagawa/ubuntu) via `theme <name>` alias. Each theme has its own `configs/starship-<name>.toml`. `switch-theme.ps1` deploys the starship config AND syncs the WT color scheme from `configs/windows-terminal.json` (so color edits take effect on next `theme` call without reinstalling). Installer always registers all schemes unconditionally — only theme activation is prompted.

## Profile Structure & Architecture

The profile loads in this order:

1. **Batch Tool Check** (`profile.ps1`) - All tools checked once and stored in `$script:ToolsAvailable` hashtable
2. **Aliases** (`scripts/aliases.ps1`) - Tool shortcuts and functions (uses cached `$ToolsAvailable`)
3. **Starship** - Prompt initialization (cached init script from `$env:TEMP\mypowershell-starship-init.ps1`)
4. **Zoxide** - Smart directory navigation (cached init script from `$env:TEMP\mypowershell-zoxide-init.ps1`)
5. **PSReadLine** - Inline history prediction (ghost text)
6. **PSFzf** - Lazy-loaded on Ctrl+R/Ctrl+T
7. **Yazi Wrapper** - File manager function (if installed)

### Key Architecture Details

**Tool Availability Caching** (v1.1.0): Instead of calling `Get-Command` multiple times across profile.ps1 and aliases.ps1, all tools are checked once at startup and stored in `$script:ToolsAvailable`. This hashtable is accessible to aliases.ps1, saving ~150ms.

**Batch Get-Command Optimization** (v1.2.0): Single `Get-Command` call for all tools instead of 9 individual calls. Results are looped to build `$ToolsAvailable` hashtable. Includes Windows `.exe` extension handling for compatibility.

**Init Script Caching** (v1.1.0): `starship init powershell` and `zoxide init powershell` spawn external processes, which is slow. Their output is cached to `$env:TEMP\mypowershell-*-init.ps1` files. Cache regenerates every 7 days or if missing, saving ~100ms per shell startup.

**Lazy-Loading PSFzf** (v1.1.0): The PSFzf module only loads when Ctrl+R or Ctrl+T is pressed. Custom keybindings call `Initialize-PSFzf` which imports the module on first use.

**.NET File APIs** (v1.2.0): Uses faster .NET methods (`[System.IO.File]::Exists()`, `GetLastWriteTime()`, `ReadAllLines()`) instead of PowerShell cmdlets for file operations, saving ~10-20ms.

## Performance Metrics

- **Warm boot**: ~28-32ms | **Cold boot**: ~190-210ms
- Tool check: 1 cached `Get-Command` batch (8 tools, 7-day TTL at `$env:TEMP\mypowershell-tools.json`)
- Init scripts: cached to `$env:TEMP\mypowershell-{starship,zoxide}-init.ps1`, 7-day TTL
- File operations: .NET APIs (`[System.IO.File]::Exists()`, `GetLastWriteTime()`, `ReadAllLines()`)

## Installation Flow

1. **Pre-flight**: Check PowerShell version (5.1+ required, 7+ recommended)
2. **Scoop**: Install if missing
3. **Starship**: winget → scoop fallback
4. **Core Tools**: winget for zoxide/fzf/eza/rg, scoop for bat/fd
5. **PSFzf Module**: Install from PowerShell Gallery
6. **Optional Tools**: Prompted for yazi only
7. **Nerd Font**: JetBrainsMono via scoop nerd-fonts bucket
8. **Windows Terminal**: Auto-inject Tokyo Night theme + font config
9. **Deploy Config**: Copy starship.toml to `~\.config\`
10. **Profile Hook**: Add to `$PROFILE`

## Uninstallation Flow

`uninstall.ps1` performs a 7-step guided removal:

1. Removes profile hook (creates timestamped backup first)
2. Removes Starship config (`~\.config\starship.toml`)
3. Removes cached init scripts from `$env:TEMP` (automatic, no prompt)
4. Optionally removes Windows Terminal themes/font settings
5. Optionally uninstalls tools (winget first, scoop fallback per tool)
6. Resets current session immediately — no restart needed
7. Shows summary

All destructive steps use default-NO confirmations. JetBrainsMono font is preserved.

## Common Issues & Fixes

**Issue**: Starship config changes not taking effect
**Fix**: Starship reads from `~\.config\starship.toml` (deployed copy), not `configs\starship.toml` (repo source). After editing, redeploy: `Copy-Item configs\starship.toml ~\.config\starship.toml` — or just run `theme <name>` which redeploys automatically.

**Issue**: Windows OS icon not rendering in prompt
**Fix**: Requires JetBrainsMono Nerd Font v3+. The icon is `󰍲` (`nf-md-windows`). Verify the font is active in Windows Terminal.

## Development Commands

### Installation & Setup
```powershell
# Run the installer
.\install.ps1

# Run installer without prompts (for testing)
.\install.ps1 -SkipConfirmation

# Run the uninstaller
.\uninstall.ps1

# Reload profile after making changes
. $PROFILE
```

### Testing & Debugging
```powershell
# Measure profile load time
Measure-Command { . $PROFILE }

# Check tool availability
Get-Command starship, zoxide, fzf, eza, bat, fd, rg, yazi

# View cached init scripts
Get-Content "$env:TEMP\mypowershell-starship-init.ps1"
Get-Content "$env:TEMP\mypowershell-zoxide-init.ps1"

# Clear cache to force regeneration
Remove-Item "$env:TEMP\mypowershell-*.ps1"

# Test individual components
. "$PSScriptRoot\scripts\aliases.ps1"  # Source aliases directly
```

## Testing Checklist

### Installation Testing
After changes, verify:
- [ ] Profile loads without errors: `. $PROFILE`
- [ ] Profile load time: `Measure-Command { . $PROFILE }`
- [ ] All tools work: `z`, `zi`, `ls`, `ll`, `cat`, `fd`, `rg`
- [ ] Keybindings work: Ctrl+R (history), Ctrl+T (files)
- [ ] Navigation shortcuts: `..`, `...`, `....`
- [ ] Yazi wrapper (if installed): `y`

### Uninstaller Testing
After running `.\uninstall.ps1`:
- [ ] Profile hook removed from `$PROFILE`
- [ ] Starship config removed (if selected)
- [ ] Cached scripts removed from `$env:TEMP`
- [ ] Prompt immediately resets to `PS C:\>` (no restart needed)
- [ ] Tools uninstalled (if selected): `Get-Command starship` returns error
- [ ] New PowerShell session loads cleanly with default prompt
- [ ] No errors on startup

## Important Notes

- **No emojis** unless explicitly requested by user
- **Performance-Critical**: Always measure impact of profile changes with `Measure-Command { . $PROFILE }`
- **Config Files**: starship.toml is deployed to `~\.config\` - always edit the repo copy then redeploy
- **Commit Co-Authoring**: Always add `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>` to commit messages
