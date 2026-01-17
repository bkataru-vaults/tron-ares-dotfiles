# Tron Ares Dotfiles

Crimson red terminal configuration inspired by Tron: Ares. Pure black backgrounds with blood-red accents.

## Components

### Terminal & Shell
| Component | Config File | Description |
|-----------|-------------|-------------|
| **WezTerm** | `wezterm/.wezterm.lua` | GPU-accelerated terminal with fancy tab bar, pulsing cursor, status bar |
| **Alacritty** | `alacritty/alacritty.toml` | Alternative terminal (WSL/Debian focused) |
| **Nushell** | `nushell/config.nu`, `nushell/env.nu` | Modern shell with PSReadLine-like keybindings |
| **PowerShell** | `powershell/Microsoft.PowerShell_profile.ps1` | PS7 profile with PSReadLine, fzf, zoxide |
| **Starship** | `starship/starship-nu.toml` | Prompt for Nushell with git metrics, battery, time |
| **Starship** | `starship/starship-pwsh.toml` | Minimal prompt for PowerShell |

### Editors
| Component | Config File | Description |
|-----------|-------------|-------------|
| **Zed** | `zed/settings.json` | Modern editor with AI agents, LSP configs |
| **Helix** | `helix/config.toml`, `helix/languages.toml` | Modal editor config |

### CLI Tools
| Component | Config File | Description |
|-----------|-------------|-------------|
| **Git** | `git/.gitconfig` | Git config with delta pager |
| **GitHub CLI** | `gh/config.yml` | gh aliases and settings |
| **Ripgrep** | `ripgrep/.ripgreprc` | Smart-case search defaults |
| **OpenCode** | `opencode/opencode.json` | AI coding assistant MCP servers |
| **Fastfetch** | `fastfetch/config.jsonc` | System info display |
| **Winfetch** | `fastfetch/winfetch.json` | Windows system info (legacy) |
| **Spotify Player** | `spotify-player/app.toml` | TUI Spotify client |

## Installation (Windows)

### Prerequisites

```powershell
# Terminal & Shell
scoop install wezterm alacritty nushell powershell starship

# CLI Tools
scoop install git gh delta ripgrep zoxide carapace-bin fnm fzf fastfetch

# Editors
scoop install zed helix

# Optional
scoop install opencode spotify-player
```

### Deploy Configs

```powershell
# === Terminal ===
Copy-Item wezterm\.wezterm.lua $HOME\.wezterm.lua
Copy-Item alacritty\alacritty.toml $env:APPDATA\alacritty\alacritty.toml

# === Shell ===
# Nushell
Copy-Item nushell\config.nu $env:APPDATA\nushell\config.nu
Copy-Item nushell\env.nu $env:APPDATA\nushell\env.nu

# PowerShell
Copy-Item powershell\Microsoft.PowerShell_profile.ps1 $HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

# Starship
mkdir -Force $HOME\.config
Copy-Item starship\starship-nu.toml $HOME\.config\starship-nu.toml
Copy-Item starship\starship-pwsh.toml $HOME\.config\starship.toml

# === Editors ===
Copy-Item zed\settings.json $env:APPDATA\Zed\settings.json
mkdir -Force $env:APPDATA\helix
Copy-Item helix\config.toml $env:APPDATA\helix\config.toml
Copy-Item helix\languages.toml $env:APPDATA\helix\languages.toml

# === CLI Tools ===
Copy-Item git\.gitconfig $HOME\.gitconfig
Copy-Item ripgrep\.ripgreprc $HOME\.ripgreprc
Copy-Item gh\config.yml $env:APPDATA\GitHub CLI\config.yml
mkdir -Force $HOME\.config\opencode
Copy-Item opencode\opencode.json $HOME\.config\opencode\opencode.json
mkdir -Force $HOME\.config\fastfetch
Copy-Item fastfetch\config.jsonc $HOME\.config\fastfetch\config.jsonc
mkdir -Force $HOME\.config\spotify-player
Copy-Item spotify-player\app.toml $HOME\.config\spotify-player\app.toml
```

### Font

Uses **JetBrainsMono Nerd Font**:

```powershell
scoop bucket add nerd-fonts
scoop install JetBrainsMono-NF
```

## Features

### WezTerm
- Tron Ares crimson color scheme
- Fancy animated tab bar with circuit-style angles
- Pulsing cursor with smooth easing
- Leader key indicator (Ctrl+A)
- Animated status bar with data flow effect
- Smart right-click (copy if selected, paste if not)
- 120fps smooth scrolling with WebGPU

### Nushell
- PSReadLine-style history navigation (Up/Down, Ctrl+P/N)
- Ctrl+R for history search
- Ctrl+F for fzf file finder
- Right arrow accepts history hints
- Tron Ares syntax highlighting colors
- Integrations: zoxide, carapace, fnm

### PowerShell
- PSReadLine with predictive IntelliSense (ListView)
- History search with Up/Down arrows
- Ctrl+F for fzf, Ctrl+R for history
- Terminal-Icons for file icons
- fnm, zoxide, starship integrations

### Starship Prompt
- Time display with Tron brackets
- Battery indicator with threshold coloring
- Git metrics (lines added/removed)
- Git state (rebase/merge/cherry-pick)
- Memory usage warning (>75%)
- Background jobs indicator

### Git
- Delta as pager for beautiful diffs
- zdiff3 conflict style for easier merges
- autocrlf disabled (consistent line endings)

## File Sizes

```
    238 B   ripgrep/
    308 B   git/
    349 B   helix/
    951 B   opencode/
    990 B   spotify-player/
   1.62 KiB gh/
   2.31 KiB powershell/
   2.33 KiB alacritty/
   2.46 KiB fastfetch/
   4.79 KiB zed/
  11.30 KiB starship/
  21.36 KiB wezterm/
  23.18 KiB nushell/
  ---------
  ~72 KiB   total
```

## Theme Colors

| Element | Hex |
|---------|-----|
| Primary Red | `#FF3333` |
| Dark Red | `#CC2222` |
| Muted Red | `#DF1F1F` |
| Background | `#000000` |
| Foreground | `#FFFFFF` |

## Notes

- **Zed settings**: API keys are templated as `${TAVILY_API_KEY}` - replace with your own
- **Paths**: Some configs use `${HOME}` or `${SCOOP}` placeholders - adjust for your system
- **OpenCode**: MCP server paths reference `C:\Users\user\.cursor\` - update as needed
