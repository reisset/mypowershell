# MyPowerShell

A high-performance PowerShell environment for Windows 11. Built to enhance productivity with modern CLI tools while maintaining PowerShell fundamentals. **Inspired by MyBash and adapted for Windows.**

## The Goods

- **Starship Prompt:** Fast, informative, and git-aware.
- **Modern Toolset:** Includes `zoxide` (smart cd), `eza` (modern ls), `bat`, `fzf`, `lazygit`, `delta`, and more.
- **Muscle Memory Safe:** Standard PowerShell commands still work - you won't get lost.
- **Visual Polish:** Tokyo Night theme, JetBrainsMono Nerd Font, syntax-highlighted diffs.
- **Fast Startup:** ~150-200ms profile load time with aggressive optimizations.

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

3. **Finish Up:**
    Restart your terminal or run `. $PROFILE`. Windows Terminal will automatically use the Nerd Font and Tokyo Night theme.

### Security

This installer:
- Does **not** require administrator privileges
- Only installs from trusted package managers (winget, scoop)
- Overwrites configs without prompting (by design for repeatability)

For detailed security information, see [SECURITY.md](SECURITY.md).

## Tweaking Configs

- **Profile:** `scripts\profile.ps1` - Main PowerShell profile
- **Aliases:** `scripts\aliases.ps1` - Modern tool aliases and shortcuts
- **Prompt:** `configs\starship.toml` - Starship configuration
- **Git Delta:** `configs\delta.gitconfig` - Git diff styling
- **ASCII Art:** `asciiart.txt` - Welcome banner

## Quick Reference

Run `tools` anytime to see the full command reference guide.

**Navigation:**
```powershell
z docs       # Jump to frequent directories
zi           # Interactive directory picker
..           # Go up one directory
```

**Git Shortcuts:**
```powershell
gs           # git status
ga .         # git add .
gc -m "msg"  # git commit
gp           # git push
lg           # LazyGit TUI
```

**Files & Search:**
```powershell
ls           # List with icons (eza)
ll           # Detailed list
cat file.txt # Syntax-highlighted view (bat)
fd pattern   # Fast file search
rg pattern   # Fast text search
Ctrl+R       # Fuzzy history search
```

## License

MIT License - see [LICENSE](LICENSE) for details.
