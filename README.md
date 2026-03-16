# MyPowerShell

A high-performance PowerShell environment for Windows 11. Built to enhance productivity with modern CLI tools while maintaining PowerShell fundamentals. **Inspired by MyBash and adapted for Windows.**

## The Goods

- **Starship Prompt:** Fast, informative, and git-aware.
- **Modern Toolset:** Includes `zoxide` (smart cd), `eza` (modern ls), `bat`, `fzf`, `fd`, `ripgrep`, and optional `yazi` file manager.
- **Muscle Memory Safe:** Standard PowerShell commands still work - you won't get lost.
- **Visual Polish:** Four switchable themes (Tokyo Night, Hack The Box, Matrix, Kanagawa), JetBrainsMono Nerd Font.
- **Fast Startup:** ~28-32ms warm profile load time with aggressive optimizations.

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
    Restart your terminal or run `. $PROFILE`. The installer will prompt you to choose a theme (Tokyo Night, Hack The Box, Matrix, or Kanagawa). Switch anytime with `theme <name>`.

### Security

This installer:
- Does **not** require administrator privileges
- Only installs from trusted package managers (winget, scoop)
- Overwrites configs without prompting (by design for repeatability)

For detailed security information, see [SECURITY.md](SECURITY.md).

## Uninstalling

To completely remove MyPowerShell and restore native PowerShell:

```powershell
.\uninstall.ps1
```

The uninstaller will:
- Remove the PowerShell profile hook (with backup)
- Optionally remove Starship config, cached scripts, and Windows Terminal theme
- Optionally uninstall all tools (starship, zoxide, eza, bat, etc.)
- Immediately reset your current session to defaults
- **Preserves JetBrainsMono Nerd Font** (it's nice to keep)

All steps are prompted with safe defaults (No). Your session resets instantly - no restart needed.

## Themes

Switch themes anytime (tab completion included):

```powershell
theme tokyo     # Tokyo Night — dark navy, blue/purple pastel
theme htb       # Hack The Box — HTB brand navy + neon green
theme matrix    # Matrix — pure black + phosphor green, all green prompt
theme kanagawa  # Kanagawa Wave — warm dark, Japanese woodblock palette
```

Each theme updates both the Starship prompt colors and Windows Terminal color scheme simultaneously. Open a new tab to see the terminal background/palette change.

## Tweaking Configs

- **Profile:** `scripts\profile.ps1` - Main PowerShell profile
- **Aliases:** `scripts\aliases.ps1` - Modern tool aliases and shortcuts
- **Prompt:** `configs\starship.toml` — Tokyo Night prompt (or `starship-htb.toml`, `starship-matrix.toml`, `starship-kanagawa.toml`)

After editing a starship config, redeploy it: `theme <name>` does this automatically, or manually:
```powershell
Copy-Item configs\starship.toml ~\.config\starship.toml
```

## Quick Reference

Run `tools` anytime to see the full command reference guide.

**Navigation:**
```powershell
z docs       # Jump to frequent directories
zi           # Interactive directory picker
..           # Go up one directory
```

**Files & Search:**
```powershell
ls           # List with icons (eza)
ll           # Detailed list
cat file.txt # Syntax-highlighted view (bat)
fd pattern   # Fast file search
rg pattern   # Fast text search
Ctrl+R       # Fuzzy history search
Ctrl+T       # Fuzzy file search
y            # Yazi file manager (optional)
```

## License

MIT License - see [LICENSE](LICENSE) for details.
