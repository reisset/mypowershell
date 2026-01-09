# Changelog

All notable changes to MyPowerShell will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.3] - 2026-01-09

### Fixed
- **Installer Hook Detection**: Fixed critical bug where empty profile after uninstall would not have hook re-added
  - `$null -notlike "*pattern*"` returns empty array in PowerShell, which evaluates to `$false`
  - Added explicit null check: `if (-not $existingContent -or $existingContent -notlike "*$profileSource*")`
  - Fixes issue where after running uninstaller, re-running installer would say "hook already exists" but leave profile empty
  - This caused all features (Starship, zoxide, aliases, ASCII art) to not work after fresh install

## [1.2.2] - 2026-01-09

### Changed
- **Installer Output**: Removed redundant text from completion message
  - Removed "Phase 3" references from banner and version comments
  - Removed duplicate "v1.0 installation complete" status line
  - Removed "Quick Start" section (delegated to `tools` command)
- **README**: Added missing tools (`dust`, `y`, `tldr`) to Quick Reference

## [1.1.1] - 2026-01-08

### Fixed
- **Uninstaller**: Fixed profile hook removal failure due to regex pattern mismatch
- **Profile Cache**: Added error handling with fallback to direct init if cache creation fails

## [1.1.0-uninstall] - 2026-01-08

### Added
- **Comprehensive Uninstaller Script** (`uninstall.ps1`)
  - Step-by-step uninstallation with safe default-NO confirmations
  - Automatic tool uninstallation (detects winget vs scoop)
  - Immediate session reset (no restart needed)
  - Removes profile hook, configs, cached scripts, git delta config
  - Optional Windows Terminal cleanup (Tokyo Night theme removal)
  - Preserves JetBrainsMono Nerd Font

## [1.2.1] - 2026-01-08

### Fixed
- **Windows .exe Extension Handling**: Fixed starship prompt detection after v1.2.0 batch optimization
  - Batch `Get-Command` returns `starship.exe` on Windows, not `starship`
  - Updated tool availability check to handle both forms

## [1.2.0] - 2026-01-08

### Changed
- **Profile Load Time**: Reduced from <250ms (v1.1.0) to ~150-200ms
  - Optimized batch `Get-Command` (single call instead of 9)
  - Removed unnecessary PSReadLine check (~20-40ms saved)
  - Combined PSReadLineOption calls
  - Used faster .NET file APIs instead of PowerShell cmdlets
  - Added Starship timeout configurations (prevents hangs)

### Fixed
- **`lsg` Function**: Fixed severe performance issue with many files
  - Changed from spawning eza per file to single batch call

## [1.1.0] - 2026-01-08

### Changed
- **Profile Load Time**: Reduced from ~500ms to <250ms (~50% improvement)
  - Batch command availability checks (~150ms saved)
  - Cached init scripts for starship and zoxide (~100ms saved)
  - Cache regenerates every 7 days or if missing

### Added
- **CLAUDE.md**: Project context file for development
- **.gitignore**: Spec file and temporary file entries

### Fixed
- **Installer**: Fixed `Confirm-No` function not found error

## [1.0.0] - 2026-01-08

### Added
- **Documentation**: README.md, TOOLS.md, LICENSE (MIT), SECURITY.md
- **Yazi Integration**: File manager wrapper (`y` command) with directory change support
- **Optional Tools**: Yazi and tealdeer (prompted during installation)

### Changed
- Updated installer completion message to reference v1.0
- Added comprehensive "Next steps" guide

## Early Development (0.1.0 - 0.3.1)

**Phase 1 (0.1.0)**: Foundation
- Starship prompt with Tokyo Night theme
- PSReadLine enhancements (history prediction, ListView mode)
- Installer with Scoop and winget support

**Phase 2 (0.2.0)**: Core Tools
- Added zoxide, fzf + PSFzf, eza, bat, fd, ripgrep
- Created aliases.ps1 with tool shortcuts and git commands
- Automatic tool loading with graceful degradation

**Phase 3 (0.3.0)**: Development Tools & Visual Polish
- Added lazygit, delta, dust
- Windows Terminal Tokyo Night theme integration
- JetBrainsMono Nerd Font installation
- Removed Terminal-Icons module (performance optimization)

**Phase 3.5 (0.3.1)**: Bug Fixes & Polish
- Fixed `Add-Member` errors in installer
- Increased default font size to 15pt
- Added ASCII art welcome banner (once per session)

---

## Installation

```powershell
cd C:\Users\YourUsername\mypowershell
.\install.ps1
```

After installation, restart your terminal or run:
```powershell
. $PROFILE
```
