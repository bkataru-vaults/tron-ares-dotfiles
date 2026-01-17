# =============================================================================
# Nushell Environment Configuration
# =============================================================================
# This file is loaded before config.nu
# Documentation: https://www.nushell.sh/book/configuration.html

# =============================================================================
# ENVIRONMENT VARIABLES
# =============================================================================

# Editor
$env.EDITOR = 'code'
$env.VISUAL = 'code'

# Locale
$env.LANG = 'en_US.UTF-8'

# FZF Configuration
$env.FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --border --info=inline --marker="*" --pointer=">" --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796,fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6,marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796'
$env.FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git'
$env.FZF_CTRL_T_COMMAND = $env.FZF_DEFAULT_COMMAND
$env.FZF_ALT_C_COMMAND = 'fd --type d --hidden --follow --exclude .git'

# BAT (better cat) configuration
$env.BAT_THEME = 'TwoDark'
$env.BAT_STYLE = 'numbers,changes,header'

# Ripgrep configuration
$env.RIPGREP_CONFIG_PATH = ($env.USERPROFILE | path join '.ripgreprc')

# Delta (git diff) configuration
$env.DELTA_PAGER = 'less -R'

# =============================================================================
# PATH CONFIGURATION
# =============================================================================

# Ensure scoop shims and other important paths are in PATH
def create_path [] {
    let base_paths = [
        ($env.USERPROFILE | path join 'scoop' 'shims')
        ($env.USERPROFILE | path join '.cargo' 'bin')
        ($env.USERPROFILE | path join 'go' 'bin')
        ($env.USERPROFILE | path join '.local' 'bin')
        ($env.USERPROFILE | path join 'bin')
        'C:\Program Files\PowerShell\7-preview'
        'C:\Program Files\Git\cmd'
    ]
    
    let existing = if 'Path' in $env { $env.Path | split row ';' } else { [] }
    
    $base_paths 
    | where { |p| ($p | path exists) and ($p not-in $existing) }
    | append $existing
    | uniq
}

$env.Path = (create_path | str join ';')

# =============================================================================
# STARSHIP PROMPT
# =============================================================================

$env.STARSHIP_SHELL = 'nu'
$env.STARSHIP_CONFIG = ($env.USERPROFILE | path join '.config' 'starship-nu.toml')

# Initialize Starship prompt (creates prompt command and right prompt)
def create_left_prompt [] {
    starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
}

# =============================================================================
# PROMPT CONFIGURATION
# =============================================================================

$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = ''
$env.PROMPT_INDICATOR = ''
$env.PROMPT_INDICATOR_VI_INSERT = ''
$env.PROMPT_INDICATOR_VI_NORMAL = ''
$env.PROMPT_MULTILINE_INDICATOR = '::: '

# =============================================================================
# NUSHELL STARTUP SETTINGS
# =============================================================================

# Use external tools for conversions
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts')
    ($nu.default-config-dir | path join 'completions')
]

$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins')
]

# =============================================================================
# CARAPACE COMPLETIONS (Multi-shell completion engine)
# =============================================================================

# Generate carapace init script for nushell
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'

# =============================================================================
# ZOXIDE (Smart cd replacement)
# =============================================================================

# Will be initialized in config.nu after shell starts

# =============================================================================
# FNM (Fast Node Manager)
# =============================================================================

# FNM configuration
$env.FNM_DIR = ($env.USERPROFILE | path join '.fnm')
$env.FNM_MULTISHELL_PATH = ($env.USERPROFILE | path join '.fnm' 'current')
$env.FNM_COREPACK_ENABLED = 'true'
$env.FNM_RESOLVE_ENGINES = 'true'

# Add FNM to path if it exists
if ($env.FNM_DIR | path exists) {
    $env.Path = ($env.FNM_DIR | append ($env.Path | split row ';') | str join ';')
}
