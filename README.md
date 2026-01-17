# Tron Ares Dotfiles

Crimson red terminal configuration inspired by Tron: Ares. Pure black backgrounds with blood-red accents.

## Components

| Component | Config File | Description |
|-----------|-------------|-------------|
| **WezTerm** | `wezterm/.wezterm.lua` | GPU-accelerated terminal with fancy tab bar, pulsing cursor, status bar |
| **Nushell** | `nushell/config.nu`, `nushell/env.nu` | Modern shell with PSReadLine-like keybindings |
| **Starship** | `starship/starship-nu.toml` | Prompt for Nushell with git metrics, battery, time |
| **Starship** | `starship/starship-pwsh.toml` | Minimal prompt for PowerShell |
| **Fastfetch** | `fastfetch/config.jsonc` | System info display |

## Installation (Windows)

### Prerequisites

Install these tools (via scoop or winget):

```powershell
# Terminal & Shell
scoop install wezterm nushell starship

# CLI Tools (used in configs)
scoop install zoxide carapace-bin fnm fzf fastfetch
```

### Deploy Configs

```powershell
# WezTerm
Copy-Item wezterm\.wezterm.lua $HOME\.wezterm.lua

# Nushell
Copy-Item nushell\config.nu $env:APPDATA\nushell\config.nu
Copy-Item nushell\env.nu $env:APPDATA\nushell\env.nu

# Starship (for Nushell)
Copy-Item starship\starship-nu.toml $HOME\.config\starship-nu.toml

# Starship (for PowerShell - optional)
Copy-Item starship\starship-pwsh.toml $HOME\.config\starship.toml

# Fastfetch
mkdir -Force $HOME\.config\fastfetch
Copy-Item fastfetch\config.jsonc $HOME\.config\fastfetch\config.jsonc
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

### Starship Prompt
- Time display with Tron brackets
- Battery indicator with threshold coloring
- Git metrics (lines added/removed)
- Git state (rebase/merge/cherry-pick)
- Memory usage warning (>75%)
- Background jobs indicator

## File Sizes

```
 1.70 KiB  fastfetch/
11.30 KiB  starship/
21.36 KiB  wezterm/
23.18 KiB  nushell/
---------
57.53 KiB  total
```

## Theme Colors

| Element | Hex |
|---------|-----|
| Primary Red | `#FF3333` |
| Dark Red | `#CC2222` |
| Muted Red | `#DF1F1F` |
| Background | `#000000` |
| Foreground | `#FFFFFF` |
