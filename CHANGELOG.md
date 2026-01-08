# Changelog

All notable changes to MyPowerShell will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned for Phase 4
- TOOLS.md quick reference documentation
- README.md with installation instructions
- LICENSE file (MIT)
- SECURITY.md
- Welcome message in profile
- Yazi file manager wrapper function (`y`)
- Optional tools (yazi, tealdeer)

## [0.3.0] - 2026-01-08

### Added - Phase 3: Development Tools & Integration
- **Development Tools**
  - lazygit for interactive Git TUI (`lg` command)
  - delta for beautiful git diffs with syntax highlighting
  - dust for visual disk usage analysis

- **Visual Enhancements**
  - Windows Terminal Tokyo Night theme integration
  - Automated JetBrainsMono Nerd Font installation via scoop
  - Tokyo Night color scheme for Windows Terminal settings

- **Configuration Files**
  - `configs/delta.gitconfig` - Git delta configuration (copied from MyBash)
  - `configs/windows-terminal.json` - Tokyo Night theme fragment

- **Installer Enhancements** (`install.ps1`)
  - Tier 2 tool installation (lazygit, delta, dust)
  - Nerd Font installation with scoop nerd-fonts bucket
  - Windows Terminal settings.json automatic theme injection
  - Optional git delta configuration (prompted)
  - Comprehensive completion message with all installed tools

### Changed
- Updated profile.ps1 to remove Terminal-Icons references (performance optimization)
- Improved PSFzf lazy-loading for faster shell startup
- Enhanced installer output with categorized tool listing

### Removed
- **Terminal-Icons module** - Removed due to ~450ms startup latency impact
  - Prioritizing performance over visual enhancements
  - Icons still work via eza and other tools

### Performance
- Profile load time optimized by removing Terminal-Icons
- Maintained sub-500ms startup target

## [0.2.0] - 2026-01-08

### Added - Phase 2: Core Tools
- **Core CLI Tools Installation**
  - zoxide for smart directory navigation (`z`, `zi`)
  - fzf for fuzzy finding with PSFzf integration
  - eza for modern file listings with icons
  - bat for syntax-highlighted file viewing
  - fd for fast file finding
  - ripgrep for fast text search

- **PowerShell Module**
  - PSFzf module for Ctrl+R (history) and Ctrl+T (file finder) keybindings

- **Aliases & Functions** (`scripts/aliases.ps1`)
  - Eza functions: `ls`, `ll`, `la`, `lt`, `lsg` (glob workaround)
  - Navigation shortcuts: `..`, `...`, `....`
  - Git shortcuts: `g`, `gs`, `ga`, `gc`, `gp`, `gl`, `gd`
  - Tool aliases: `cat` → `bat`, `grep` → `rg`, `find` → `fd`
  - `zi` for interactive zoxide directory picker
  - `tools` function for quick reference (TOOLS.md to be created in Phase 4)

- **Profile Enhancements** (`scripts/profile.ps1`)
  - Automatic sourcing of aliases.ps1
  - Zoxide initialization
  - FZF + PSFzf setup with keybindings
  - Conditional tool loading (graceful degradation if tools missing)

- **Installer Improvements** (`install.ps1`)
  - Tier 1 tool installation via winget + scoop
  - Automatic fallback from winget to scoop if installation fails
  - PowerShell module installation (PSFzf)
  - Tool installation tracking and status reporting
  - Enhanced completion message with quick start guide

### Changed
- Configuration files now overwrite automatically (removed confirmation prompt)
- Updated profile to Phase 2 with full tool initialization
- Improved installer output with comprehensive tool listing

## [0.1.0] - 2026-01-08

### Added - Phase 1: Foundation
- **Project Structure**
  - Created `configs/`, `scripts/`, `docs/` directories
  - Project specification document (`mypowershell-spec.md`)

- **Starship Prompt** (`configs/starship.toml`)
  - Adapted from MyBash with Tokyo Night color palette
  - Two-line prompt format with directory, git branch, and language modules
  - Added Windows OS symbol (󰍲)
  - Custom colors for prompt elements

- **PowerShell Profile** (`scripts/profile.ps1`)
  - Starship prompt initialization
  - PSReadLine enhancements (history prediction, ListView mode)
  - Emacs-style editing keybindings
  - Better history search with Up/Down arrows
  - Conditional tool loading pattern

- **Installer Script** (`install.ps1`)
  - PowerShell version checking (5.1+ required, 7+ recommended)
  - Scoop package manager installation
  - Starship installation via winget (with scoop fallback)
  - Configuration file deployment to `~\.config\`
  - PowerShell profile hook setup
  - Helper functions: `Test-CommandExists`, `Install-WingetPackage`, `Install-ScoopPackage`, `Confirm`
  - Pragmatic error handling (warn and continue)

### Technical Details
- UTF-8 encoding for all PowerShell scripts
- No administrator privileges required
- Cross-platform config reuse from MyBash (starship.toml, delta.gitconfig)
- Incremental installation approach

---

## Version Numbering

- **0.1.0** - Phase 1: Foundation (Starship + basic profile)
- **0.2.0** - Phase 2: Core Tools (zoxide, fzf, eza, bat, fd, ripgrep)
- **0.3.0** - Phase 3: Development Tools (lazygit, delta, dust, WT theme)
- **0.4.0** - Phase 4: Documentation & Polish
- **1.0.0** - Full Release (all phases complete)

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
