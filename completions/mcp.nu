# MCP CLI completions for Nushell

def "nu-complete mcp servers" [] {
    ^mcp list --json | from json | transpose name server | get name
}

def "nu-complete mcp shells" [] {
    ["bash", "elvish", "fish", "powershell", "zsh"]
}

def "nu-complete mcp runtimes" [] {
    ["node", "bun", "deno", "npx", "bunx"]
}

# MCP server manager CLI
export extern "mcp" [
    --mcp-dir: path  # Path to MCP directory
    --help(-h)       # Print help
    --version(-V)    # Print version
]

# List all configured MCP servers
export extern "mcp list" [
    --enabled(-e)    # Show only enabled servers
    --disabled(-d)   # Show only disabled servers
    --json           # Output as JSON
    --mcp-dir: path  # Path to MCP directory
    --help(-h)       # Print help
]

# Run an MCP server
export extern "mcp run" [
    name: string@"nu-complete mcp servers"  # Server name
    --mcp-dir: path  # Path to MCP directory
    --help(-h)       # Print help
    ...args          # Additional arguments
]

# Generate Cursor and OpenCode configuration files
export extern "mcp gen" [
    --cursor         # Only generate Cursor config
    --opencode       # Only generate OpenCode config
    --dry-run(-d)    # Dry run - print configs without writing
    --mcp-dir: path  # Path to MCP directory
    --help(-h)       # Print help
]

# Add a new MCP server
export extern "mcp add" [
    name: string               # Server name
    --runtime(-r): string@"nu-complete mcp runtimes"  # Runtime
    --path(-p): string         # Path to server entry point
    --description(-d): string  # Description
    --tools(-t): string        # Tool names (comma-separated)
    --env(-e): string          # Environment variables (comma-separated)
    --disabled                 # Mark as disabled
    --opencode-only            # Mark as OpenCode-only
    --mcp-dir: path            # Path to MCP directory
    --help(-h)                 # Print help
]

# Remove an MCP server
export extern "mcp remove" [
    name: string@"nu-complete mcp servers"  # Server name
    --force(-f)      # Skip confirmation
    --mcp-dir: path  # Path to MCP directory
    --help(-h)       # Print help
]

# Enable an MCP server
export extern "mcp enable" [
    name: string@"nu-complete mcp servers"  # Server name
    --mcp-dir: path  # Path to MCP directory
    --help(-h)       # Print help
]

# Disable an MCP server
export extern "mcp disable" [
    name: string@"nu-complete mcp servers"  # Server name
    --mcp-dir: path  # Path to MCP directory
    --help(-h)       # Print help
]

# Show server details
export extern "mcp show" [
    name: string@"nu-complete mcp servers"  # Server name
    --json           # Output as JSON
    --mcp-dir: path  # Path to MCP directory
    --help(-h)       # Print help
]

# Manage environment variables
export extern "mcp env" [
    --mcp-dir: path  # Path to MCP directory
    --help(-h)       # Print help
]

# List environment variables
export extern "mcp env list" [
    --mcp-dir: path  # Path to MCP directory
    --help(-h)       # Print help
]

# Set an environment variable
export extern "mcp env set" [
    key: string      # Variable name
    value: string    # Variable value
    --mcp-dir: path  # Path to MCP directory
    --help(-h)       # Print help
]

# Remove an environment variable
export extern "mcp env remove" [
    key: string      # Variable name
    --mcp-dir: path  # Path to MCP directory
    --help(-h)       # Print help
]

# Edit .env file in default editor
export extern "mcp env edit" [
    --mcp-dir: path  # Path to MCP directory
    --help(-h)       # Print help
]

# Show paths and configuration
export extern "mcp info" [
    --mcp-dir: path  # Path to MCP directory
    --help(-h)       # Print help
]

# Generate shell completions
export extern "mcp completions" [
    shell: string@"nu-complete mcp shells"  # Shell to generate completions for
    --mcp-dir: path  # Path to MCP directory
    --help(-h)       # Print help
]
