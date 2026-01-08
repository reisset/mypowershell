# MyPowerShell - Context for Claude

This document provides context for Claude Code when working on the MyPowerShell project.

## Project Overview

**MyPowerShell** is a high-performance PowerShell environment for Windows 11, inspired by [MyBash](https://github.com/reisset/mybash) for Linux. It enhances the PowerShell experience with modern CLI tools while preserving muscle memory for standard commands.

**Version**: v1.0.0 (Phase 5 in progress for v1.1.0)
**Repository**: https://github.com/reisset/mypowershell
**License**: MIT

## Philosophy

- **Learning-First**: Modern tools enhance PowerShell, but standard commands remain untouched
- **Performance**: Sub-500ms profile load time (targeting <250ms in v1.1.0)
- **Pragmatic Error Handling**: Warns on errors but continues installation
- **No Admin Required**: All tools install to user directories via Scoop/winget
- **Muscle Memory Safe**: Works on vanilla systems - you won't get lost

## File Structure

```
mypowershell/
├── install.ps1                  # Main installer (winget/scoop)
├── scripts/
│   ├── profile.ps1             # Main profile (starship, zoxide, fzf, PSReadLine)
│   └── aliases.ps1             # Tool aliases (eza, bat, fd, rg, git shortcuts)
├── configs/
│   ├── starship.toml           # Starship prompt config (Tokyo Night)
│   ├── windows-terminal.json   # WT theme fragment (Tokyo Night + JetBrainsMono 15pt)
│   └── delta.gitconfig         # Git delta config (copied from MyBash)
├── docs/
│   └── TOOLS.md                # Quick reference guide
├── asciiart.txt                # Welcome banner (shown once per session)
├── README.md                   # User documentation
├── SECURITY.md                 # Security policy
├── CHANGELOG.md                # Version history
├── LICENSE                     # MIT License
└── CLAUDE.md                   # This file
```

## Tools Installed

### Core Tools (Tier 1)
- **Starship**: Fast, git-aware prompt
- **zoxide**: Smart directory navigation (`z`, `zi`)
- **fzf + PSFzf**: Fuzzy finder (Ctrl+R for history, Ctrl+T for files)
- **eza**: Modern ls with icons (`ls`, `ll`, `la`, `lt`)
- **bat**: Syntax-highlighted cat
- **fd**: Fast file finder (aliased to `find`)
- **ripgrep**: Fast text search (`rg`, aliased to `grep`)

### Development Tools (Tier 2)
- **lazygit**: Git TUI (`lg`)
- **delta**: Beautiful git diffs
- **dust**: Disk usage analyzer

### Optional Tools
- **yazi**: Terminal file manager (`y`)
- **tealdeer**: Quick command examples (`tldr`)

### Visual Enhancements
- **JetBrainsMono Nerd Font**: Installed via scoop nerd-fonts bucket
- **Tokyo Night Theme**: Auto-injected into Windows Terminal
- **ASCII Art Banner**: Displayed once per session

## Key Design Decisions

1. **No Terminal-Icons module**: Removed due to ~450ms startup penalty
2. **Font Size**: 15pt (user preference, 12pt was too small)
3. **PSReadLine + Ctrl+R**: Both kept - complementary features (inline vs full-screen)
4. **PSFzf Lazy-Loading**: Module loads only when Ctrl+R or Ctrl+T pressed
5. **Config Overwrites**: Automatic without prompting (for repeatability)
6. **Welcome Banner**: Once per session via `$env:MYPOWERSHELL_WELCOME_SHOWN`
7. **Yazi Wrapper**: Allows directory changes after exiting file manager

## Profile Structure

The profile loads in this order:

1. **Aliases** (`scripts/aliases.ps1`) - Tool shortcuts and functions
2. **Starship** - Prompt initialization
3. **PSReadLine** - History, predictions, keybindings
4. **Zoxide** - Smart directory navigation
5. **PSFzf** - Lazy-loaded on Ctrl+R/Ctrl+T
6. **Yazi Wrapper** - File manager function (if installed)
7. **Welcome Banner** - ASCII art (once per session)

## Current State (v1.0.0)

**Completed Phases:**
- ✅ Phase 1: Foundation (Starship prompt + basic structure)
- ✅ Phase 2: Core Tools (zoxide, fzf, eza, bat, fd, ripgrep)
- ✅ Phase 3: Development Tools (lazygit, delta, dust + WT theme)
- ✅ Phase 3.5: Bug Fixes (font size, ASCII banner, Add-Member -Force)
- ✅ Phase 4: Documentation (README, TOOLS.md, LICENSE, SECURITY.md)

**In Progress:**
- 🔄 Phase 5: Performance Optimization (v1.1.0)
  - Fix `Confirm-No` installer bug
  - Batch command checks (~150ms saved)
  - Cache init scripts (~100ms saved)
  - Target: <250ms profile load time

## Performance Targets

| Metric | v1.0.0 | v1.1.0 Target |
|--------|--------|---------------|
| Profile load time | ~500ms | <250ms |
| Get-Command checks | 10+ individual | 1 batch |
| Init script calls | 2 (spawn each time) | 0 (cached) |

## Installation Flow

1. **Pre-flight**: Check PowerShell version (5.1+ required, 7+ recommended)
2. **Scoop**: Install if missing
3. **Starship**: winget → scoop fallback
4. **Tier 1 Tools**: winget for zoxide/fzf/eza/rg, scoop for bat/fd
5. **PSFzf Module**: Install from PowerShell Gallery
6. **Tier 2 Tools**: winget for lazygit, scoop for delta/dust
7. **Optional Tools**: Prompted for yazi/tealdeer
8. **Nerd Font**: JetBrainsMono via scoop nerd-fonts bucket
9. **Windows Terminal**: Auto-inject Tokyo Night theme + font config
10. **Git Delta**: Optional (prompted, default no)
11. **Profile Hook**: Add to `$PROFILE`

## Common Issues & Fixes

**Issue**: `Add-Member` error "member already exists" (install.ps1:390, 400, 408)
**Fix**: Added `-Force` parameter to all `Add-Member` calls

**Issue**: Profile load time ~500ms
**Fix**: Batch command checks + cache init scripts (Phase 5)

**Issue**: `Confirm-No` function not found
**Fix**: Change to `Confirm "..." -DefaultYes $false`

## Testing Checklist

After changes, verify:
- [ ] Profile loads without errors: `. $PROFILE`
- [ ] Profile load time: `Measure-Command { . $PROFILE }`
- [ ] All tools work: `z`, `zi`, `ls`, `ll`, `cat`, `fd`, `rg`, `lg`, `dust`
- [ ] Keybindings work: Ctrl+R (history), Ctrl+T (files)
- [ ] Git shortcuts: `gs`, `ga`, `gc`, `gp`, `gl`, `gd`
- [ ] Welcome banner shows once per session
- [ ] `tools` command displays TOOLS.md

## Related Projects

- **MyBash**: Linux/Bash equivalent at `C:\Users\Forensic 64032\mybash\`
- **Reference Configs**: starship.toml and delta.gitconfig copied from MyBash

## Notes for Claude

- **No emojis** unless explicitly requested
- **Standard output** for user communication (not bash echo)
- **Read before edit** - always use Read tool before modifying files
- **Commit messages**: Follow conventional commits (e.g., "feat:", "fix:", "perf:")
- **Co-Authored-By**: Add `Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>`
- **Performance**: Measure impact of changes with `Measure-Command`
- **MyBash Reference**: Available at `C:\Users\Forensic 64032\mybash\` for cross-referencing patterns
