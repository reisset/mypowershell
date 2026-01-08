# MyPowerShell

A high-performance PowerShell environment for Windows 11. Built to enhance productivity with modern CLI tools while maintaining PowerShell fundamentals. **Inspired by MyBash and adapted for Windows.**

## The Goods

- **Starship Prompt:** Fast, informative, and git-aware cross-shell prompt.
- **Modern Toolset:** Includes `zoxide` (smart cd), `eza` (modern ls), `bat`, `fzf`, `lazygit`, `delta`, and more.
- **Muscle Memory Safe:** Standard PowerShell commands still work - you won't get lost on vanilla systems.
- **Visual Polish:** Tokyo Night theme, JetBrainsMono Nerd Font, syntax-highlighted diffs.
- **Fast Startup:** ~150-200ms profile load time (v1.2.0) with aggressive optimizations.

## Quick Start

Don't just run random scripts from the internet. Read the code first.

1. **Clone & Inspect:**
    ```powershell
    git clone https://github.com/reisset/mypowershell.git
    cd mypowershell
    Get-Content install.ps1  # Review before running
    ```

2. **Install:**
    ```powershell
    .\install.ps1
    ```
    The installer will:
    - Install Scoop package manager (if needed)
    - Install Starship prompt via winget/scoop
    - Install modern CLI tools (zoxide, fzf, eza, bat, fd, ripgrep, lazygit, delta, dust)
    - Install JetBrainsMono Nerd Font
    - Configure Windows Terminal with Tokyo Night theme
    - Set up PowerShell profile with all integrations

3. **Finish Up:**
    - Restart your terminal or run `. $PROFILE`
    - Windows Terminal will automatically use the Nerd Font and Tokyo Night theme
    - Open a new tab to see the ASCII art welcome banner

## Features

### Core Tools (Tier 1)
| Tool | Command | Purpose |
|------|---------|---------|
| **zoxide** | `z`, `zi` | Smart directory navigation - jumps to frequent folders |
| **fzf + PSFzf** | `Ctrl+R`, `Ctrl+T` | Fuzzy finder for history and files |
| **eza** | `ls`, `ll`, `la`, `lt` | Modern file listings with icons |
| **bat** | `cat` | Syntax-highlighted file viewer |
| **fd** | `fd`, `find` | Fast file search |
| **ripgrep** | `rg`, `grep` | Ultra-fast text search |

### Development Tools (Tier 2)
| Tool | Command | Purpose |
|------|---------|---------|
| **lazygit** | `lg` | Git TUI for commits, branches, rebasing |
| **delta** | `git diff` | Beautiful git diffs with syntax highlighting |
| **dust** | `dust` | Visual disk usage analyzer |

### Visual Enhancements
- **Starship Prompt:** Two-line format with directory, git branch, language versions
- **Tokyo Night Theme:** Applied to Windows Terminal automatically
- **JetBrainsMono Nerd Font:** Icons in prompt and file listings
- **ASCII Art Banner:** Displays on first terminal launch

## Security

This installer:
- Does **not** require administrator privileges
- Only installs from trusted package managers (winget, scoop)
- Automatically falls back to scoop if winget fails
- Overwrites configs without prompting (by design for repeatability)
- Uses pragmatic error handling (warns and continues)

For detailed security information, see [SECURITY.md](SECURITY.md).

## Configuration Files

- **Profile:** `scripts\profile.ps1` - Main PowerShell profile
- **Aliases:** `scripts\aliases.ps1` - Modern tool aliases and shortcuts
- **Prompt:** `configs\starship.toml` - Starship configuration
- **Git Delta:** `configs\delta.gitconfig` - Git diff styling
- **Windows Terminal:** `configs\windows-terminal.json` - Tokyo Night theme fragment
- **ASCII Art:** `asciiart.txt` - Welcome banner

## Quick Reference

Run `tools` anytime to see the full command reference guide.

### Navigation
```powershell
z docs          # Jump to frequently used 'docs' directory
zi              # Interactive directory picker
..              # Go up one directory
...             # Go up two directories
```

### Git Shortcuts
```powershell
g               # Alias for git
gs              # git status
ga .            # git add .
gc -m "msg"     # git commit -m "msg"
gp              # git push
lg              # Open LazyGit TUI
```

### File Operations
```powershell
ls              # List files with icons
ll              # Detailed list with permissions
la              # List all files including hidden
lt              # Tree view of directory
cat file.txt    # View file with syntax highlighting
```

### Search
```powershell
fd pattern      # Fast file search
rg pattern      # Fast text search
Ctrl+R          # Fuzzy search history
Ctrl+T          # Fuzzy find files
```

## Customization

### Power Mode (Optional)
Want `cd` to use `z` (zoxide) automatically? Uncomment the "POWER MODE" section in `scripts\aliases.ps1`:

```powershell
# Uncomment to replace cd with z
Remove-Alias -Name cd -Force -ErrorAction SilentlyContinue
Set-Alias -Name cd -Value z -Option AllScope
```

**Warning:** This breaks muscle memory for vanilla Windows systems.

## Uninstalling

To remove MyPowerShell:

1. Remove the profile hook from `$PROFILE`:
   ```powershell
   code $PROFILE  # Remove the MyPowerShell section
   ```

2. Optionally uninstall tools via scoop/winget:
   ```powershell
   scoop uninstall starship bat fd delta dust
   winget uninstall starship zoxide fzf eza ripgrep lazygit
   ```

3. Delete configuration files:
   ```powershell
   Remove-Item ~\.config\starship.toml
   ```

## Performance

- **Profile Load Time:** ~150-200ms (v1.2.0 with aggressive optimizations)
  - v1.0.0: ~500ms baseline
  - v1.1.0: <250ms (batch checks + init caching)
  - v1.2.0: ~150-200ms (optimized Get-Command, .NET APIs, removed redundant checks)
- **No Terminal-Icons:** Removed due to ~450ms startup penalty
- **PSFzf Lazy-Loading:** Only loads when Ctrl+R or Ctrl+T is pressed
- **Batch Tool Detection:** Single Get-Command call for all tools
- **.NET File APIs:** Uses faster .NET methods instead of PowerShell cmdlets
- **Starship Timeouts:** 30s scan timeout, 500ms command timeout prevents hangs

## Requirements

- **OS:** Windows 10/11
- **PowerShell:** 5.1+ (PowerShell 7+ recommended)
- **Terminal:** Windows Terminal recommended (for full theme support)
- **Internet:** Required for initial tool installation

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Credits

- Inspired by [MyBash](https://github.com/reisset/mybash)
- Built with modern CLI tools from the Rust ecosystem
- Starship prompt by [starship.rs](https://starship.rs)
- Tokyo Night theme by [enkia](https://github.com/enkia/tokyo-night-vscode-theme)

---

**Enjoying MyPowerShell?** Star the repo and share it with fellow PowerShell users!
