use anyhow::{Context, Result};
use clap::{CommandFactory, Parser, Subcommand};
use clap_complete::{generate, Shell};
use colored::Colorize;
use serde::{Deserialize, Serialize};
use std::collections::BTreeMap;
use std::fs;
use std::io;
use std::path::PathBuf;
use std::process::{Command, Stdio};
use tabled::{Table, Tabled};

/// MCP (Model Context Protocol) Server Manager
#[derive(Parser)]
#[command(name = "mcp")]
#[command(author, version, about, long_about = None)]
#[command(propagate_version = true)]
struct Cli {
    #[command(subcommand)]
    command: Commands,

    /// Path to MCP directory (default: ~/.mcp)
    #[arg(long, global = true)]
    mcp_dir: Option<PathBuf>,
}

#[derive(Subcommand)]
enum Commands {
    /// List all configured MCP servers
    List {
        /// Show only enabled servers
        #[arg(short, long)]
        enabled: bool,

        /// Show only disabled servers
        #[arg(short, long)]
        disabled: bool,

        /// Output as JSON
        #[arg(long)]
        json: bool,
    },

    /// Run an MCP server
    Run {
        /// Server name (from servers.json)
        name: String,

        /// Additional arguments to pass to the server
        #[arg(trailing_var_arg = true)]
        args: Vec<String>,
    },

    /// Generate Cursor and OpenCode configuration files
    Gen {
        /// Only generate Cursor config
        #[arg(long)]
        cursor: bool,

        /// Only generate OpenCode config
        #[arg(long)]
        opencode: bool,

        /// Dry run - print configs without writing
        #[arg(short, long)]
        dry_run: bool,
    },

    /// Add a new MCP server
    Add {
        /// Server name
        name: String,

        /// Runtime (node, bun, deno, npx, bunx)
        #[arg(short, long, default_value = "node")]
        runtime: String,

        /// Path to server entry point
        #[arg(short, long)]
        path: String,

        /// Description
        #[arg(short, long)]
        description: Option<String>,

        /// Tool names (comma-separated)
        #[arg(short, long)]
        tools: Option<String>,

        /// Environment variables required (comma-separated)
        #[arg(short, long)]
        env: Option<String>,

        /// Mark as disabled
        #[arg(long)]
        disabled: bool,

        /// Mark as OpenCode-only
        #[arg(long)]
        opencode_only: bool,
    },

    /// Remove an MCP server
    Remove {
        /// Server name
        name: String,

        /// Skip confirmation
        #[arg(short, long)]
        force: bool,
    },

    /// Enable an MCP server
    Enable {
        /// Server name
        name: String,
    },

    /// Disable an MCP server
    Disable {
        /// Server name
        name: String,
    },

    /// Show server details
    Show {
        /// Server name
        name: String,

        /// Output as JSON
        #[arg(long)]
        json: bool,
    },

    /// Manage environment variables
    Env {
        #[command(subcommand)]
        action: EnvCommands,
    },

    /// Show paths and configuration
    Info,

    /// Generate shell completions
    Completions {
        /// Shell to generate completions for
        #[arg(value_enum)]
        shell: Shell,
    },
}

#[derive(Subcommand)]
enum EnvCommands {
    /// List environment variables
    List,

    /// Set an environment variable
    Set {
        /// Variable name
        key: String,
        /// Variable value
        value: String,
    },

    /// Remove an environment variable
    Remove {
        /// Variable name
        key: String,
    },

    /// Edit .env file in default editor
    Edit,
}

// ============================================================================
// Data Structures
// ============================================================================

#[derive(Debug, Serialize, Deserialize)]
struct ServersConfig {
    #[serde(rename = "$schema", skip_serializing_if = "Option::is_none")]
    schema: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    description: Option<String>,
    servers: BTreeMap<String, Server>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct Server {
    #[serde(skip_serializing_if = "Option::is_none")]
    runtime: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    path: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    args: Option<Vec<String>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    description: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    tools: Option<Vec<String>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    env: Option<Vec<String>>,
    #[serde(default)]
    disabled: bool,
    #[serde(default, skip_serializing_if = "std::ops::Not::not")]
    opencode_only: bool,
    #[serde(rename = "type", skip_serializing_if = "Option::is_none")]
    server_type: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    url: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    command: Option<String>,
}

#[derive(Tabled)]
struct ServerRow {
    #[tabled(rename = "Name")]
    name: String,
    #[tabled(rename = "Runtime")]
    runtime: String,
    #[tabled(rename = "Status")]
    status: String,
    #[tabled(rename = "Description")]
    description: String,
}

// ============================================================================
// Path Management
// ============================================================================

struct McpPaths {
    mcp_dir: PathBuf,
    servers_json: PathBuf,
    env_file: PathBuf,
    #[allow(dead_code)]
    node_version: PathBuf,
    cursor_config: PathBuf,
    opencode_config: PathBuf,
    fnm_node_modules: PathBuf,
    bun_node_modules: PathBuf,
}

impl McpPaths {
    fn new(mcp_dir: Option<PathBuf>) -> Result<Self> {
        let home = dirs::home_dir().context("Could not determine home directory")?;
        let mcp_dir = mcp_dir.unwrap_or_else(|| home.join(".mcp"));

        Ok(Self {
            servers_json: mcp_dir.join("servers.json"),
            env_file: mcp_dir.join(".env"),
            node_version: mcp_dir.join(".node-version"),
            cursor_config: home.join(".cursor").join("mcp.json"),
            opencode_config: home.join(".config").join("opencode").join("opencode.json"),
            fnm_node_modules: home
                .join("AppData")
                .join("Roaming")
                .join("fnm")
                .join("aliases")
                .join("default")
                .join("node_modules"),
            bun_node_modules: home
                .join(".bun")
                .join("install")
                .join("global")
                .join("node_modules"),
            mcp_dir,
        })
    }

    fn ensure_mcp_dir(&self) -> Result<()> {
        if !self.mcp_dir.exists() {
            fs::create_dir_all(&self.mcp_dir)?;
        }
        Ok(())
    }
}

// ============================================================================
// Config Loading
// ============================================================================

fn load_servers(paths: &McpPaths) -> Result<ServersConfig> {
    let content = fs::read_to_string(&paths.servers_json)
        .with_context(|| format!("Failed to read {}", paths.servers_json.display()))?;
    serde_json::from_str(&content).context("Failed to parse servers.json")
}

fn save_servers(paths: &McpPaths, config: &ServersConfig) -> Result<()> {
    let content = serde_json::to_string_pretty(config)?;
    fs::write(&paths.servers_json, content)?;
    Ok(())
}

fn load_env(paths: &McpPaths) -> BTreeMap<String, String> {
    let mut env = BTreeMap::new();
    if let Ok(content) = fs::read_to_string(&paths.env_file) {
        for line in content.lines() {
            let line = line.trim();
            if line.is_empty() || line.starts_with('#') {
                continue;
            }
            if let Some((key, value)) = line.split_once('=') {
                env.insert(key.trim().to_string(), value.trim().to_string());
            }
        }
    }
    env
}

fn save_env(paths: &McpPaths, env: &BTreeMap<String, String>) -> Result<()> {
    let mut content = String::from("# MCP Server Environment Variables\n\n");
    for (key, value) in env {
        content.push_str(&format!("{}={}\n", key, value));
    }
    fs::write(&paths.env_file, content)?;
    Ok(())
}

// ============================================================================
// Commands
// ============================================================================

fn cmd_list(paths: &McpPaths, enabled: bool, disabled: bool, json: bool) -> Result<()> {
    let config = load_servers(paths)?;

    let servers: Vec<_> = config
        .servers
        .iter()
        .filter(|(_, s)| {
            if enabled {
                !s.disabled
            } else if disabled {
                s.disabled
            } else {
                true
            }
        })
        .collect();

    if json {
        let map: BTreeMap<_, _> = servers.into_iter().collect();
        println!("{}", serde_json::to_string_pretty(&map)?);
        return Ok(());
    }

    let rows: Vec<ServerRow> = servers
        .iter()
        .map(|(name, server)| {
            let runtime = if server.server_type.as_deref() == Some("remote") {
                "remote".to_string()
            } else if server.server_type.as_deref() == Some("native") {
                "native".to_string()
            } else {
                server.runtime.clone().unwrap_or_else(|| "node".to_string())
            };

            let status = if server.disabled {
                "disabled".red().to_string()
            } else {
                "enabled".green().to_string()
            };

            ServerRow {
                name: name.to_string(),
                runtime,
                status,
                description: server
                    .description
                    .clone()
                    .unwrap_or_default()
                    .chars()
                    .take(40)
                    .collect(),
            }
        })
        .collect();

    if rows.is_empty() {
        println!("{}", "No servers found.".yellow());
    } else {
        let table = Table::new(rows).to_string();
        println!("{}", table);
        println!(
            "\n{} servers total",
            config.servers.len().to_string().cyan()
        );
    }

    Ok(())
}

fn cmd_run(paths: &McpPaths, name: &str, extra_args: &[String]) -> Result<()> {
    let config = load_servers(paths)?;
    let server = config
        .servers
        .get(name)
        .with_context(|| format!("Server '{}' not found", name))?;

    // Load environment variables
    let env_vars = load_env(paths);

    // Determine how to run the server
    if server.server_type.as_deref() == Some("remote") {
        anyhow::bail!("Cannot run remote server '{}' - it connects via URL", name);
    }

    if server.server_type.as_deref() == Some("native") {
        // Native binary
        let cmd = server
            .command
            .as_ref()
            .context("Native server missing 'command'")?;
        let args = server.args.clone().unwrap_or_default();

        let mut command = Command::new(cmd);
        command.args(&args).args(extra_args);

        for (k, v) in &env_vars {
            command.env(k, v);
        }

        let status = command.status()?;
        std::process::exit(status.code().unwrap_or(1));
    }

    // Runtime-based server (node, bun, deno, npx, bunx)
    let runtime = server.runtime.as_deref().unwrap_or("node");
    let path = server.path.as_ref().context("Server missing 'path'")?;
    let server_args = server.args.clone().unwrap_or_default();

    let (program, args) = match runtime {
        "node" => {
            let script = paths.fnm_node_modules.join(path);
            ("node".to_string(), vec![script.to_string_lossy().to_string()])
        }
        "bun" => {
            let script = paths.bun_node_modules.join(path);
            (
                "bun".to_string(),
                vec!["run".to_string(), script.to_string_lossy().to_string()],
            )
        }
        "deno" => (
            "deno".to_string(),
            vec!["run".to_string(), "--allow-all".to_string(), path.clone()],
        ),
        "npx" => ("npx".to_string(), vec!["-y".to_string(), path.clone()]),
        "bunx" => ("bunx".to_string(), vec![path.clone()]),
        _ => anyhow::bail!("Unknown runtime: {}", runtime),
    };

    // For node runtime, we need to set up fnm PATH
    let mut command = Command::new(&program);
    command
        .args(&args)
        .args(&server_args)
        .args(extra_args)
        .stdin(Stdio::inherit())
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit());

    // Set environment variables
    for (k, v) in &env_vars {
        command.env(k, v);
    }

    // For node, prepend fnm to PATH
    if runtime == "node" || runtime == "npx" {
        let fnm_path = paths
            .fnm_node_modules
            .parent()
            .unwrap()
            .to_string_lossy()
            .to_string();
        let current_path = std::env::var("PATH").unwrap_or_default();
        command.env("PATH", format!("{};{}", fnm_path, current_path));
    }

    let status = command.status()?;
    std::process::exit(status.code().unwrap_or(1));
}

fn cmd_gen(paths: &McpPaths, cursor_only: bool, opencode_only: bool, dry_run: bool) -> Result<()> {
    let config = load_servers(paths)?;

    let gen_cursor = !opencode_only;
    let gen_opencode = !cursor_only;

    if gen_cursor {
        let cursor_config = generate_cursor_config(&config, paths);
        let json = serde_json::to_string_pretty(&cursor_config)?;

        if dry_run {
            println!("{}", "=== Cursor Config ===".cyan());
            println!("{}", json);
        } else {
            if let Some(parent) = paths.cursor_config.parent() {
                fs::create_dir_all(parent)?;
            }
            fs::write(&paths.cursor_config, &json)?;
            println!(
                "{} {}",
                "Wrote:".green(),
                paths.cursor_config.display()
            );
        }
    }

    if gen_opencode {
        let opencode_config = generate_opencode_config(&config, paths);
        let json = serde_json::to_string_pretty(&opencode_config)?;

        if dry_run {
            println!("{}", "=== OpenCode Config ===".cyan());
            println!("{}", json);
        } else {
            if let Some(parent) = paths.opencode_config.parent() {
                fs::create_dir_all(parent)?;
            }
            fs::write(&paths.opencode_config, &json)?;
            println!(
                "{} {}",
                "Wrote:".green(),
                paths.opencode_config.display()
            );
        }
    }

    if !dry_run {
        println!("{}", "Done!".green());
    }

    Ok(())
}

fn generate_cursor_config(
    config: &ServersConfig,
    paths: &McpPaths,
) -> serde_json::Value {
    let mut mcp_servers = serde_json::Map::new();

    for (name, server) in &config.servers {
        // Skip OpenCode-only servers
        if server.opencode_only {
            continue;
        }

        let mut entry = serde_json::Map::new();
        entry.insert("disabled".to_string(), serde_json::json!(server.disabled));

        if server.server_type.as_deref() == Some("remote") {
            entry.insert("url".to_string(), serde_json::json!(server.url));
        } else if server.server_type.as_deref() == Some("native") {
            entry.insert("command".to_string(), serde_json::json!(server.command));
            entry.insert("args".to_string(), serde_json::json!(server.args.clone().unwrap_or_default()));
        } else {
            let runtime = server.runtime.as_deref().unwrap_or("node");
            let path = server.path.as_deref().unwrap_or("");
            let spec = format!("{}:{}", runtime, path);
            
            let mut args = vec![
                "/c".to_string(),
                paths.mcp_dir.join("mcp-run.cmd").to_string_lossy().to_string(),
                spec,
            ];
            if let Some(extra) = &server.args {
                args.extend(extra.clone());
            }

            entry.insert("command".to_string(), serde_json::json!("cmd.exe"));
            entry.insert("args".to_string(), serde_json::json!(args));
        }

        let tools = server.tools.clone().unwrap_or_default();
        entry.insert("alwaysAllow".to_string(), serde_json::json!(tools));

        mcp_servers.insert(name.clone(), serde_json::Value::Object(entry));
    }

    serde_json::json!({ "mcpServers": mcp_servers })
}

fn generate_opencode_config(
    config: &ServersConfig,
    paths: &McpPaths,
) -> serde_json::Value {
    let mut mcp = serde_json::Map::new();

    for (name, server) in &config.servers {
        let mut entry = serde_json::Map::new();

        if server.server_type.as_deref() == Some("remote") {
            entry.insert("type".to_string(), serde_json::json!("remote"));
            entry.insert("url".to_string(), serde_json::json!(server.url));
        } else if server.server_type.as_deref() == Some("native") {
            entry.insert("type".to_string(), serde_json::json!("local"));
            let mut cmd = vec![server.command.clone().unwrap_or_default()];
            cmd.extend(server.args.clone().unwrap_or_default());
            entry.insert("command".to_string(), serde_json::json!(cmd));
        } else {
            let runtime = server.runtime.as_deref().unwrap_or("node");
            let path = server.path.as_deref().unwrap_or("");
            let spec = format!("{}:{}", runtime, path);

            let mut cmd = vec![
                "cmd.exe".to_string(),
                "/c".to_string(),
                paths.mcp_dir.join("mcp-run.cmd").to_string_lossy().to_string(),
                spec,
            ];
            if let Some(extra) = &server.args {
                cmd.extend(extra.clone());
            }

            entry.insert("type".to_string(), serde_json::json!("local"));
            entry.insert("command".to_string(), serde_json::json!(cmd));
        }

        mcp.insert(name.clone(), serde_json::Value::Object(entry));
    }

    serde_json::json!({
        "mcp": mcp,
        "$schema": "https://opencode.ai/config.json"
    })
}

fn cmd_add(
    paths: &McpPaths,
    name: String,
    runtime: String,
    path: String,
    description: Option<String>,
    tools: Option<String>,
    env: Option<String>,
    disabled: bool,
    opencode_only: bool,
) -> Result<()> {
    let mut config = load_servers(paths)?;

    if config.servers.contains_key(&name) {
        anyhow::bail!("Server '{}' already exists", name);
    }

    let server = Server {
        runtime: Some(runtime),
        path: Some(path),
        args: None,
        description,
        tools: tools.map(|t| t.split(',').map(|s| s.trim().to_string()).collect()),
        env: env.map(|e| e.split(',').map(|s| s.trim().to_string()).collect()),
        disabled,
        opencode_only,
        server_type: None,
        url: None,
        command: None,
    };

    config.servers.insert(name.clone(), server);
    save_servers(paths, &config)?;

    println!("{} Added server '{}'", "✓".green(), name.cyan());
    Ok(())
}

fn cmd_remove(paths: &McpPaths, name: &str, force: bool) -> Result<()> {
    let mut config = load_servers(paths)?;

    if !config.servers.contains_key(name) {
        anyhow::bail!("Server '{}' not found", name);
    }

    if !force {
        eprint!(
            "Remove server '{}'? [y/N] ",
            name.cyan()
        );
        let mut input = String::new();
        std::io::stdin().read_line(&mut input)?;
        if !input.trim().eq_ignore_ascii_case("y") {
            println!("Cancelled.");
            return Ok(());
        }
    }

    config.servers.remove(name);
    save_servers(paths, &config)?;

    println!("{} Removed server '{}'", "✓".green(), name);
    Ok(())
}

fn cmd_enable(paths: &McpPaths, name: &str) -> Result<()> {
    let mut config = load_servers(paths)?;

    let server = config
        .servers
        .get_mut(name)
        .with_context(|| format!("Server '{}' not found", name))?;

    server.disabled = false;
    save_servers(paths, &config)?;

    println!("{} Enabled server '{}'", "✓".green(), name.cyan());
    Ok(())
}

fn cmd_disable(paths: &McpPaths, name: &str) -> Result<()> {
    let mut config = load_servers(paths)?;

    let server = config
        .servers
        .get_mut(name)
        .with_context(|| format!("Server '{}' not found", name))?;

    server.disabled = true;
    save_servers(paths, &config)?;

    println!("{} Disabled server '{}'", "✓".green(), name.cyan());
    Ok(())
}

fn cmd_show(paths: &McpPaths, name: &str, json: bool) -> Result<()> {
    let config = load_servers(paths)?;

    let server = config
        .servers
        .get(name)
        .with_context(|| format!("Server '{}' not found", name))?;

    if json {
        println!("{}", serde_json::to_string_pretty(server)?);
    } else {
        println!("{}: {}", "Name".cyan(), name);
        if let Some(desc) = &server.description {
            println!("{}: {}", "Description".cyan(), desc);
        }

        let runtime = if server.server_type.as_deref() == Some("remote") {
            "remote"
        } else if server.server_type.as_deref() == Some("native") {
            "native"
        } else {
            server.runtime.as_deref().unwrap_or("node")
        };
        println!("{}: {}", "Runtime".cyan(), runtime);

        if let Some(path) = &server.path {
            println!("{}: {}", "Path".cyan(), path);
        }
        if let Some(url) = &server.url {
            println!("{}: {}", "URL".cyan(), url);
        }
        if let Some(cmd) = &server.command {
            println!("{}: {}", "Command".cyan(), cmd);
        }
        if let Some(args) = &server.args {
            println!("{}: {:?}", "Args".cyan(), args);
        }

        println!(
            "{}: {}",
            "Status".cyan(),
            if server.disabled {
                "disabled".red()
            } else {
                "enabled".green()
            }
        );

        if server.opencode_only {
            println!("{}: yes", "OpenCode Only".cyan());
        }

        if let Some(tools) = &server.tools {
            println!("{}: {}", "Tools".cyan(), tools.join(", "));
        }
        if let Some(env) = &server.env {
            println!("{}: {}", "Env Vars".cyan(), env.join(", "));
        }
    }

    Ok(())
}

fn cmd_env(paths: &McpPaths, action: EnvCommands) -> Result<()> {
    match action {
        EnvCommands::List => {
            let env = load_env(paths);
            if env.is_empty() {
                println!("{}", "No environment variables set.".yellow());
            } else {
                for (key, value) in &env {
                    // Mask sensitive values
                    let display_value = if key.to_lowercase().contains("key")
                        || key.to_lowercase().contains("secret")
                        || key.to_lowercase().contains("token")
                    {
                        format!("{}...", &value.chars().take(8).collect::<String>())
                    } else {
                        value.clone()
                    };
                    println!("{}={}", key.cyan(), display_value);
                }
            }
        }
        EnvCommands::Set { key, value } => {
            let mut env = load_env(paths);
            env.insert(key.clone(), value);
            save_env(paths, &env)?;
            println!("{} Set {}", "✓".green(), key.cyan());
        }
        EnvCommands::Remove { key } => {
            let mut env = load_env(paths);
            if env.remove(&key).is_some() {
                save_env(paths, &env)?;
                println!("{} Removed {}", "✓".green(), key);
            } else {
                println!("{} '{}' not found", "!".yellow(), key);
            }
        }
        EnvCommands::Edit => {
            paths.ensure_mcp_dir()?;
            if !paths.env_file.exists() {
                fs::write(&paths.env_file, "# MCP Environment Variables\n")?;
            }

            let editor = std::env::var("EDITOR").unwrap_or_else(|_| "notepad".to_string());
            Command::new(&editor)
                .arg(&paths.env_file)
                .status()?;
        }
    }

    Ok(())
}

fn cmd_info(paths: &McpPaths) -> Result<()> {
    println!("{}", "MCP Configuration".cyan().bold());
    println!();
    println!("{}: {}", "MCP Directory".cyan(), paths.mcp_dir.display());
    println!("{}: {}", "Servers Config".cyan(), paths.servers_json.display());
    println!("{}: {}", "Environment".cyan(), paths.env_file.display());
    println!();
    println!("{}", "Output Paths".cyan().bold());
    println!("{}: {}", "Cursor Config".cyan(), paths.cursor_config.display());
    println!("{}: {}", "OpenCode Config".cyan(), paths.opencode_config.display());
    println!();
    println!("{}", "Runtime Paths".cyan().bold());
    println!("{}: {}", "fnm node_modules".cyan(), paths.fnm_node_modules.display());
    println!("{}: {}", "bun node_modules".cyan(), paths.bun_node_modules.display());

    // Check if paths exist
    println!();
    println!("{}", "Status".cyan().bold());

    let check = |path: &PathBuf, name: &str| {
        if path.exists() {
            println!("  {} {}", "✓".green(), name);
        } else {
            println!("  {} {} (missing)", "✗".red(), name);
        }
    };

    check(&paths.servers_json, "servers.json");
    check(&paths.env_file, ".env");
    check(&paths.cursor_config, "Cursor config");
    check(&paths.opencode_config, "OpenCode config");
    check(&paths.fnm_node_modules, "fnm node_modules");
    check(&paths.bun_node_modules, "bun node_modules");

    Ok(())
}

fn cmd_completions(shell: Shell) -> Result<()> {
    let mut cmd = Cli::command();
    generate(shell, &mut cmd, "mcp", &mut io::stdout());
    Ok(())
}

// ============================================================================
// Main
// ============================================================================

fn main() -> Result<()> {
    let cli = Cli::parse();
    let paths = McpPaths::new(cli.mcp_dir)?;

    match cli.command {
        Commands::List { enabled, disabled, json } => {
            cmd_list(&paths, enabled, disabled, json)
        }
        Commands::Run { name, args } => {
            cmd_run(&paths, &name, &args)
        }
        Commands::Gen { cursor, opencode, dry_run } => {
            cmd_gen(&paths, cursor, opencode, dry_run)
        }
        Commands::Add {
            name,
            runtime,
            path,
            description,
            tools,
            env,
            disabled,
            opencode_only,
        } => cmd_add(
            &paths,
            name,
            runtime,
            path,
            description,
            tools,
            env,
            disabled,
            opencode_only,
        ),
        Commands::Remove { name, force } => {
            cmd_remove(&paths, &name, force)
        }
        Commands::Enable { name } => {
            cmd_enable(&paths, &name)
        }
        Commands::Disable { name } => {
            cmd_disable(&paths, &name)
        }
        Commands::Show { name, json } => {
            cmd_show(&paths, &name, json)
        }
        Commands::Env { action } => {
            cmd_env(&paths, action)
        }
        Commands::Info => {
            cmd_info(&paths)
        }
        Commands::Completions { shell } => {
            cmd_completions(shell)
        }
    }
}
