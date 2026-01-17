# Tron CLI completions for Nushell

def "nu-complete tron configs" [] {
    ^tron list --json | from json | get name
}

def "nu-complete tron categories" [] {
    ^tron list --json | from json | get category | uniq
}

def "nu-complete tron shells" [] {
    ["bash", "elvish", "fish", "powershell", "zsh"]
}

# Tron Ares dotfiles manager CLI
export extern "tron" [
    --config: path   # Path to tron.toml config file
    --help(-h)       # Print help
    --version(-V)    # Print version
]

# Show sync status of all configs
export extern "tron status" [
    --category(-c): string@"nu-complete tron categories"  # Filter by category
    --outdated(-o)   # Show only out-of-sync configs
    --config: path   # Path to tron.toml config file
    --help(-h)       # Print help
]

# List all managed configs
export extern "tron list" [
    --category(-c): string@"nu-complete tron categories"  # Filter by category
    --json           # Output as JSON
    --config: path   # Path to tron.toml config file
    --help(-h)       # Print help
]

# Deploy configs from repo to system
export extern "tron deploy" [
    ...names: string@"nu-complete tron configs"  # Config names to deploy
    --category(-c): string@"nu-complete tron categories"  # Deploy entire category
    --dry-run(-d)    # Dry run - show what would be deployed
    --force(-f)      # Force overwrite even if system file is newer
    --config: path   # Path to tron.toml config file
    --help(-h)       # Print help
]

# Backup configs from system to repo
export extern "tron backup" [
    ...names: string@"nu-complete tron configs"  # Config names to backup
    --category(-c): string@"nu-complete tron categories"  # Backup entire category
    --dry-run(-d)    # Dry run - show what would be backed up
    --force(-f)      # Force overwrite even if repo file is newer
    --config: path   # Path to tron.toml config file
    --help(-h)       # Print help
]

# Show diff between repo and system
export extern "tron diff" [
    name: string@"nu-complete tron configs"  # Config name to diff
    --reverse(-r)    # Show system -> repo diff
    --config: path   # Path to tron.toml config file
    --help(-h)       # Print help
]

# Edit a config file
export extern "tron edit" [
    name: string@"nu-complete tron configs"  # Config name to edit
    --system(-s)     # Edit system file instead of repo file
    --config: path   # Path to tron.toml config file
    --help(-h)       # Print help
]

# Show config paths
export extern "tron show" [
    name: string@"nu-complete tron configs"  # Config name
    --config: path   # Path to tron.toml config file
    --help(-h)       # Print help
]

# Open dotfiles repo in file manager
export extern "tron open" [
    --config: path   # Path to tron.toml config file
    --help(-h)       # Print help
]

# Run MCP subcommand (delegates to mcp CLI)
export extern "tron mcp" [
    --config: path   # Path to tron.toml config file
    --help(-h)       # Print help
    ...args          # Arguments to pass to mcp CLI
]

# Show categories
export extern "tron categories" [
    --config: path   # Path to tron.toml config file
    --help(-h)       # Print help
]

# Initialize tron.toml in dotfiles repo
export extern "tron init" [
    --repo(-r): path # Path to dotfiles repo
    --config: path   # Path to tron.toml config file
    --help(-h)       # Print help
]

# Generate shell completions
export extern "tron completions" [
    shell: string@"nu-complete tron shells"  # Shell to generate completions for
    --config: path   # Path to tron.toml config file
    --help(-h)       # Print help
]
