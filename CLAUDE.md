# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Project Overview

**MyPowerShell** is a high-performance PowerShell environment for Windows 11, inspired by [MyBash](https://github.com/reisset/mybash) for Linux. It enhances the PowerShell experience with modern CLI tools while preserving muscle memory for standard commands.

**Version**: v2.0.1
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
├── uninstall.ps1                # Comprehensive uninstaller (v1.1.0)
├── scripts/
│   ├── profile.ps1             # Main profile (starship, zoxide, fzf)
│   └── aliases.ps1             # Tool aliases (eza, bat, fd, rg)
├── configs/
│   ├── starship.toml           # Starship prompt config (Tokyo Night)
│   └── windows-terminal.json   # WT theme fragment (Tokyo Night + JetBrainsMono 15pt)
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
- **Tokyo Night Theme**: Auto-injected into Windows Terminal
- **OS Icon**: Windows Nerd Font glyph in prompt (`󰍲`, nf-md-windows)

## Key Design Decisions

1. **No Terminal-Icons module**: Removed due to ~450ms startup penalty
2. **Font Size**: 15pt (user preference, 12pt was too small)
3. **PSFzf Lazy-Loading**: Module loads only when Ctrl+R or Ctrl+T pressed
4. **Config Overwrites**: Automatic without prompting (for repeatability)
5. **Yazi Wrapper**: Allows directory changes after exiting file manager
6. **Deployed Config**: Starship reads from `~\.config\starship.toml`, not the repo copy

## Profile Structure & Architecture

The profile loads in this order:

1. **Batch Tool Check** (`profile.ps1`) - All tools checked once and stored in `$script:ToolsAvailable` hashtable
2. **Aliases** (`scripts/aliases.ps1`) - Tool shortcuts and functions (uses cached `$ToolsAvailable`)
3. **Starship** - Prompt initialization (cached init script from `$env:TEMP\mypowershell-starship-init.ps1`)
4. **Zoxide** - Smart directory navigation (cached init script from `$env:TEMP\mypowershell-zoxide-init.ps1`)
5. **PSFzf** - Lazy-loaded on Ctrl+R/Ctrl+T
6. **Yazi Wrapper** - File manager function (if installed)

### Key Architecture Details

**Tool Availability Caching** (v1.1.0): Instead of calling `Get-Command` multiple times across profile.ps1 and aliases.ps1, all tools are checked once at startup and stored in `$script:ToolsAvailable`. This hashtable is accessible to aliases.ps1, saving ~150ms.

**Batch Get-Command Optimization** (v1.2.0): Single `Get-Command` call for all tools instead of 9 individual calls. Results are looped to build `$ToolsAvailable` hashtable. Includes Windows `.exe` extension handling for compatibility.

**Init Script Caching** (v1.1.0): `starship init powershell` and `zoxide init powershell` spawn external processes, which is slow. Their output is cached to `$env:TEMP\mypowershell-*-init.ps1` files. Cache regenerates every 7 days or if missing, saving ~100ms per shell startup.

**Lazy-Loading PSFzf** (v1.1.0): The PSFzf module only loads when Ctrl+R or Ctrl+T is pressed. Custom keybindings call `Initialize-PSFzf` which imports the module on first use.

**.NET File APIs** (v1.2.0): Uses faster .NET methods (`[System.IO.File]::Exists()`, `GetLastWriteTime()`, `ReadAllLines()`) instead of PowerShell cmdlets for file operations, saving ~10-20ms.

## Current State (v2.0.1)

**Completed Phases:**
- ✅ Phase 1-4: Foundation, Core Tools, Dev Tools, Documentation
- ✅ Phase 5: Performance Optimization (v1.1.0)
  - Batch command checks, cached init scripts
  - Achieved: <250ms profile load time
- ✅ Phase 6: Advanced Performance (v1.2.0-v1.2.1)
  - Optimized batch Get-Command, .NET file APIs
  - Fixed Windows .exe extension handling
  - Achieved: ~150-200ms profile load time
- ✅ Phase 7: Uninstaller (v1.1.0-uninstall)
  - Comprehensive uninstall.ps1 with automatic tool removal
  - Immediate session reset (no restart needed)
- ✅ Phase 8: Critical Bug Fixes (v1.2.3-v1.2.4)
  - Fixed null profile detection (installer skipped hook after uninstall)
  - Fixed Windows Terminal font config (hashtable vs PSCustomObject serialization)
  - Ensures clean uninstall → reinstall workflow
- ✅ Phase 9: Essential Tools Enhancement (v1.3.0)
  - Added jq, gsudo, glow (later removed in v2.0.0)
- ✅ Phase 10: Critical Performance Fixes (v1.4.0)
  - Fixed broken Starship caching
  - Added tool availability caching to file (7-day cache)
  - Achieved: ~42ms warm boot, ~270ms cold boot
- ✅ Phase 11: Speedier Overhaul (v2.0.0)
  - Removed dev tools: lazygit, delta, dust
  - Removed optional tools: tealdeer, glow, jq, gsudo
  - Removed PSReadLine customizations (predictions, keybindings)
  - Removed ASCII welcome banner
  - Removed git shortcuts
  - Switched to minimal Starship config
  - Achieved: ~28-32ms warm boot, ~190-210ms cold boot
- ✅ Phase 12: Cleanup & Bug Fixes (v2.0.1)
  - Fixed Windows OS icon in Starship (was empty string, now `󰍲` nf-md-windows)
  - Fixed config deployment (edits must go to `~\.config\starship.toml`)
  - Removed custom.docker Starship module (unused subprocess per-prompt)
  - Removed lsg function, delta.gitconfig, speedierpwsh/ directory
  - Replaced Test-Path with .NET File API for consistency

## Performance Metrics

| Metric | v1.0.0 | v1.1.0 | v1.2.0 | v1.4.0 | v2.0.0 |
|--------|--------|--------|--------|--------|--------|
| Profile load time (warm) | ~500ms | <250ms | ~150-200ms | ~42ms | ~28-32ms |
| Profile load time (cold) | ~1000ms | ~600ms | ~500ms | ~270ms | ~190-210ms |
| Get-Command batching | 10+ individual | 1 batch (9 calls) | 1 batch (1 call) | Cached (7 days) | Cached (8 tools) |
| Init script calls | 2 (spawn each time) | 0 (cached) | 0 (cached - broken) | 0 (cached - fixed) | 0 (cached) |
| PSReadLine config | Full | Full | Full | Full | None (default) |
| Tools checked | 12 | 12 | 12 | 12 | 8 |
| File operations | Cmdlets | Cmdlets | .NET APIs | .NET APIs | .NET APIs |

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

## Uninstallation Flow (v2.0.0)

**Script**: `uninstall.ps1` - 7-step process with MyBash-inspired design

**Step 1: PowerShell Profile Cleanup**
- Detects MyPowerShell hook by `# MyPowerShell Configuration` marker
- Creates timestamped backup: `$PROFILE.mypowershell-backup-yyyyMMdd-HHmmss`
- Removes hook block via regex pattern

**Step 2: Starship Configuration**
- Removes `$env:USERPROFILE\.config\starship.toml`

**Step 3: Cached Init Scripts** (automatic, no prompt)
- Removes `$env:TEMP\mypowershell-starship-init.ps1`
- Removes `$env:TEMP\mypowershell-zoxide-init.ps1`

**Step 4: Windows Terminal** (optional)
- Removes "Tokyo Night" from color schemes array
- Removes `colorScheme`, `font.face`, `font.size`, `padding` from default profile
- Does NOT reset to Windows defaults - just removes what we added

**Step 5: Automatic Tool Uninstallation** (prompted per category)
- **Core Tools**: starship, zoxide, fzf, eza, bat, fd, ripgrep (prompted)
- **Optional Tools**: yazi (prompted)
- **PSFzf Module**: `Uninstall-Module PSFzf -AllVersions` (prompted)
- Tries winget first, falls back to scoop automatically
- Shows progress: "✓ tool uninstalled" or "- not found"

**Step 6: Immediate Session Reset** (automatic)
- Resets prompt function: `function prompt { "PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) " }`
- Disables PSReadLine predictions: `Set-PSReadLineOption -PredictionSource None`
- Clears environment variables: `STARSHIP_CONFIG`, `MYPOWERSHELL_WELCOME_SHOWN`
- User sees native PowerShell immediately, no restart needed

**Step 7: Summary**
- Lists all actions performed
- Shows checkmarks for session reset confirmation
- Notes that new sessions will be clean

**Design Philosophy**:
- Default-NO confirmations (safe by default)
- MyBash-inspired: color-coded logging, step-by-step process
- Preserves JetBrainsMono Nerd Font (user preference: "good to leave behind")
- Manual commands shown only if tools skipped

## Common Issues & Fixes

**Issue**: After uninstall + reinstall, nothing works (no Starship, zoxide, aliases, ASCII art)
**Fix** (v1.2.3): Empty profile bug - `$null -notlike "*pattern*"` returns empty array in PowerShell, which is falsy. Added explicit null check: `if (-not $existingContent -or $existingContent -notlike "*$profileSource*")`

**Issue**: After uninstall + reinstall, Windows Terminal font stays on Cascadia Mono instead of JetBrainsMono
**Fix** (v1.2.4): Hashtable serialization bug - NoteProperties added to `@{}` via Add-Member don't serialize to JSON. Changed to `[PSCustomObject]@{}` in install.ps1:424, 432.

**Issue**: Starship prompt disappeared after v1.2.0 update
**Fix** (v1.2.1): Windows .exe extension handling - batch Get-Command returns `starship.exe`, not `starship`. Check both forms.

**Issue**: Starship config changes not taking effect
**Fix** (v2.0.1): Starship reads from `~\.config\starship.toml` (deployed copy), not `mypowershell\configs\starship.toml` (repo source). After editing the repo copy, redeploy: `Copy-Item configs\starship.toml ~\.config\starship.toml`

**Issue**: Windows OS icon not rendering in prompt
**Fix** (v2.0.1): Original `Windows = ""` was empty string (no glyph). Replaced with `󰍲` (`nf-md-windows`). Requires JetBrainsMono Nerd Font v3+.

**Issue**: Profile load time ~500ms
**Fix** (v1.1.0): Batch command checks + cache init scripts → <250ms

**Issue**: Profile load time still ~250ms
**Fix** (v1.2.0): Optimized batch Get-Command, .NET file APIs, removed PSReadLine check → ~150-200ms

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

### Git Workflow
```powershell
# Stage changes
git add .

# Commit with conventional commit format
git commit -m "type: description

Detailed explanation if needed"

# Common commit types: feat, fix, perf, docs, refactor, test, chore

# Push changes
git push
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
- **MyBash Reference**: Linux equivalent at `C:\Users\Forensic 64032\mybash\` for cross-referencing patterns
- **Config Files**: starship.toml is deployed to `~\.config\` - always edit the repo copy then redeploy
- **Commit Co-Authoring**: Always add `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>` to commit messages
