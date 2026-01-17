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
| **Fastfetch** | `fastfetch/config.jsonc` | System info display |
| **Winfetch** | `fastfetch/winfetch.json` | Windows system info (legacy) |
| **Spotify Player** | `spotify-player/app.toml` | TUI Spotify client |

### MCP Infrastructure
| Component | Config File | Description |
|-----------|-------------|-------------|
| **MCP Runner** | `mcp/mcp-run.cmd` | Universal MCP server runner (Node/Bun/Deno) |
| **MCP Runner (PS)** | `mcp/mcp-run.ps1` | PowerShell version |
| **Server Definitions** | `mcp/servers.json` | Single source of truth for all MCP servers |
| **Config Generator** | `mcp/mcp-gen-config.ps1` | Generates Cursor and OpenCode configs |
| **PATH Shim** | `bin/mcp-run.cmd` | Shim for `~/bin` (in PATH) |
| **OpenCode Config** | `opencode/opencode.json` | Generated OpenCode MCP config |

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

# === MCP Infrastructure ===
# Create directories
mkdir -Force $HOME\.mcp
mkdir -Force $HOME\bin

# Copy MCP files
Copy-Item mcp\mcp-run.cmd $HOME\.mcp\mcp-run.cmd
Copy-Item mcp\mcp-run.ps1 $HOME\.mcp\mcp-run.ps1
Copy-Item mcp\servers.json $HOME\.mcp\servers.json
Copy-Item mcp\mcp-gen-config.ps1 $HOME\.mcp\mcp-gen-config.ps1
Copy-Item mcp\.node-version $HOME\.mcp\.node-version
Copy-Item mcp\.env.example $HOME\.mcp\.env  # Edit with your API keys!

# PATH shim
Copy-Item bin\mcp-run.cmd $HOME\bin\mcp-run.cmd

# Generate Cursor and OpenCode configs
& $HOME\.mcp\mcp-gen-config.ps1
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

### MCP Infrastructure
- **Universal runner** supporting multiple runtimes:
  - `node:` - Run via fnm (Fast Node Manager)
  - `bun:` - Run via Bun runtime
  - `deno:` - Run via Deno runtime
  - `npx:` - Auto-install and run via npx
  - `bunx:` - Auto-install and run via bunx
- **Single source of truth** - `servers.json` defines all MCP servers once
- **Config generator** - Generates Cursor and OpenCode configs automatically
- **Environment isolation** - `.env` file for API keys (never committed)
- **17 MCP servers** pre-configured:
  - Thinking tools (sequential, structured, shannon, stochastic, clear-thought)
  - Search (Tavily, g-search)
  - Documentation (context7, package-docs, gitmcp)
  - Utilities (chrome-devtools, postmancer, json, fetcher)
  - Project management (Linear)

## File Sizes

```
     1 KiB   bin/
     1 KiB   git/
     1 KiB   ripgrep/
     2 KiB   helix/
     4 KiB   alacritty/
     4 KiB   gh/
     4 KiB   opencode/
     4 KiB   powershell/
     4 KiB   spotify-player/
     8 KiB   fastfetch/
     8 KiB   zed/
    16 KiB   mcp/
    16 KiB   starship/
    24 KiB   wezterm/
    28 KiB   nushell/
   ---------
   ~120 KiB  total
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
- **MCP**: After deployment, edit `~/.mcp/.env` with your API keys, then run `mcp-gen-config.ps1` to regenerate configs
- **Cursor/OpenCode configs**: Generated files - edit `servers.json` and regenerate instead of editing directly
