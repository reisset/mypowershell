# MyPowerShell - Modern CLI Tools Guide

Welcome to the **Learning-First** toolset for Windows. This guide helps you navigate modern CLI tools while keeping your PowerShell fundamentals strong.

## Quick Access

- **Get-Command** - PowerShell's built-in command discovery
- **Get-Help <command>** - PowerShell's help system

## Philosophy: Learning-First
MyPowerShell adds powerful modern tools but **does not replace** PowerShell fundamentals.
- `cd`, `Get-ChildItem`, `Get-Process`, and `Get-Content` work exactly as they do in standard PowerShell.
- Modern tools are provided as **separate commands or aliases** (e.g., `z`, `fd`, `rg`).
- This ensures your skills remain compatible with vanilla Windows systems and corporate environments.

---

## Tool Reference

### Navigation & File Management
| Modern Tool | Command | PowerShell Equivalent | Why use it? |
| :--- | :--- | :--- | :--- |
| **zoxide** | `z`, `zi` | `cd`, `Set-Location` | Jumps to frequent directories by name. |
| **fd** | `fd`, `find` | `Get-ChildItem -Recurse` | Much faster, simpler syntax, ignores `.git`. |
| **fzf** | `Ctrl+t`, `Ctrl+r` | Manual search | Fuzzy finder with live previews. |
| **eza** | `ls`, `ll`, `la`, `lt` | `Get-ChildItem`, `dir` | Beautiful file listings with icons and colors. |
| **bat** | `cat` | `Get-Content`, `gc` | Syntax highlighting for file viewing. |
| **ripgrep** | `rg`, `grep` | `Select-String`, `sls` | Ultra-fast text search across files. |

### File Manager
| Modern Tool | Command | Description |
| :--- | :--- | :--- |
| **yazi** | `y` | Modern TUI file manager (optional). |

### Prompt
| Modern Tool | Command | Description |
| :--- | :--- | :--- |
| **starship** | Auto-loads | Cross-shell prompt with git branch indicator. |

---

## Quick Shortcuts & Aliases

### Navigation
- `z <dir>` - Jump to frequently used directories
- `zi` - Interactive directory picker (zoxide + fzf)
- `..` - Go up one directory (`cd ..`)
- `...` - Go up two directories (`cd ..\..`)
- `....` - Go up three directories

### File Operations
- `ls` - List files with icons (eza)
- `ll` - Detailed list with permissions and sizes (eza -al)
- `la` - List all files including hidden (eza -a)
- `lt` - Tree view of directory structure (eza --tree)
- `cat <file>` - View file with syntax highlighting (bat)

### Search & Find
- `fd <pattern>` - Fast file search
- `rg <pattern>` - Fast text search in files
- `find <pattern>` - Alias for fd
- `grep <pattern>` - Alias for rg
- `Ctrl+R` - Fuzzy search command history
- `Ctrl+T` - Fuzzy find files in current directory

### File Manager
- `y` - Open yazi file manager (if installed)

---

## PowerShell-Specific Tips

### PowerShell Native Commands Still Work
- `Get-ChildItem` / `gci` / `dir` - Standard file listing
- `Get-Content` / `gc` / `type` - Read file contents
- `Select-String` / `sls` - Search text in files
- `Get-Process` / `gps` / `ps` - List processes
- `Get-Service` - List Windows services
- `Get-Help` - PowerShell documentation

### Discovering Commands
```powershell
Get-Command *process*     # Find commands about processes
Get-Alias ls              # See what 'ls' points to
Get-Help Get-ChildItem    # Read full help for a command
```

---

## Visual Enhancements

- **Nerd Font**: JetBrainsMono Nerd Font (installed via scoop)
- **Themes**: Four switchable themes — `theme tokyo`, `theme htb`, `theme matrix`, `theme kanagawa`
- **Icons**: Supported in eza and starship prompt (requires Nerd Font)

---

## Profile Location

- **Starship Config**: `~\.config\starship.toml`
- **Profile Location**: `$PROFILE` (run to see path)
