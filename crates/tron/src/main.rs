use anyhow::{Context, Result};
use clap::{CommandFactory, Parser, Subcommand};
use clap_complete::{generate, Shell};
use colored::Colorize;
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use similar::{ChangeTag, TextDiff};
use std::collections::HashMap;
use std::fs;
use std::io;
use std::path::PathBuf;
use std::process::Command;
use tabled::{Table, Tabled};

/// Tron Ares Dotfiles Manager
#[derive(Parser)]
#[command(name = "tron")]
#[command(author, version, about = "Tron Ares dotfiles and config manager")]
#[command(propagate_version = true)]
struct Cli {
    #[command(subcommand)]
    command: Commands,

    /// Path to tron.toml config file
    #[arg(long, global = true)]
    config: Option<PathBuf>,
}

#[derive(Subcommand)]
enum Commands {
    /// Show sync status of all configs
    Status {
        /// Filter by category
        #[arg(short, long)]
        category: Option<String>,

        /// Show only out-of-sync configs
        #[arg(short, long)]
        outdated: bool,
    },

    /// List all managed configs
    List {
        /// Filter by category
        #[arg(short, long)]
        category: Option<String>,

        /// Output as JSON
        #[arg(long)]
        json: bool,
    },

    /// Deploy configs from repo to system
    Deploy {
        /// Config name(s) to deploy (omit for all)
        names: Vec<String>,

        /// Deploy entire category
        #[arg(short, long)]
        category: Option<String>,

        /// Dry run - show what would be deployed
        #[arg(short, long)]
        dry_run: bool,

        /// Force overwrite even if system file is newer
        #[arg(short, long)]
        force: bool,
    },

    /// Backup configs from system to repo
    Backup {
        /// Config name(s) to backup (omit for all)
        names: Vec<String>,

        /// Backup entire category
        #[arg(short, long)]
        category: Option<String>,

        /// Dry run - show what would be backed up
        #[arg(short, long)]
        dry_run: bool,

        /// Force overwrite even if repo file is newer
        #[arg(short, long)]
        force: bool,
    },

    /// Show diff between repo and system
    Diff {
        /// Config name to diff
        name: String,

        /// Show system -> repo diff (default is repo -> system)
        #[arg(short, long)]
        reverse: bool,
    },

    /// Edit a config file
    Edit {
        /// Config name to edit
        name: String,

        /// Edit system file instead of repo file
        #[arg(short, long)]
        system: bool,
    },

    /// Show config paths
    Show {
        /// Config name
        name: String,
    },

    /// Open dotfiles repo in file manager
    Open,

    /// Run MCP subcommand (delegates to mcp CLI)
    Mcp {
        /// Arguments to pass to mcp CLI
        #[arg(trailing_var_arg = true)]
        args: Vec<String>,
    },

    /// Show categories
    Categories,

    /// Initialize tron.toml in dotfiles repo
    Init {
        /// Path to dotfiles repo
        #[arg(short, long)]
        repo: Option<PathBuf>,
    },

    /// Generate shell completions
    Completions {
        /// Shell to generate completions for
        #[arg(value_enum)]
        shell: Shell,
    },
}

// ============================================================================
// Configuration
// ============================================================================

#[derive(Debug, Deserialize, Serialize)]
struct TronConfig {
    dotfiles: DotfilesConfig,
    config: Vec<ConfigEntry>,
}

#[derive(Debug, Deserialize, Serialize)]
struct DotfilesConfig {
    repo_path: String,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
struct ConfigEntry {
    name: String,
    category: String,
    repo_path: String,
    system_path: String,
}

#[derive(Debug, Clone)]
struct ResolvedConfig {
    name: String,
    category: String,
    repo_path: PathBuf,
    system_path: PathBuf,
}

#[derive(Debug, PartialEq)]
enum SyncStatus {
    Synced,
    RepoNewer,
    SystemNewer,
    Conflict,
    RepoMissing,
    SystemMissing,
    BothMissing,
}

impl SyncStatus {
    fn display(&self) -> colored::ColoredString {
        match self {
            SyncStatus::Synced => "✓ synced".green(),
            SyncStatus::RepoNewer => "→ repo newer".cyan(),
            SyncStatus::SystemNewer => "← system newer".yellow(),
            SyncStatus::Conflict => "⚡ conflict".red(),
            SyncStatus::RepoMissing => "? repo missing".red(),
            SyncStatus::SystemMissing => "? system missing".magenta(),
            SyncStatus::BothMissing => "✗ both missing".red(),
        }
    }
}

#[derive(Tabled)]
struct StatusRow {
    #[tabled(rename = "Name")]
    name: String,
    #[tabled(rename = "Category")]
    category: String,
    #[tabled(rename = "Status")]
    status: String,
}

#[derive(Tabled)]
struct ListRow {
    #[tabled(rename = "Name")]
    name: String,
    #[tabled(rename = "Category")]
    category: String,
    #[tabled(rename = "Repo Path")]
    repo_path: String,
    #[tabled(rename = "System Path")]
    system_path: String,
}

// ============================================================================
// Path Resolution
// ============================================================================

fn expand_path(path: &str) -> PathBuf {
    let home = dirs::home_dir().unwrap_or_else(|| PathBuf::from("."));
    let appdata = std::env::var("APPDATA")
        .map(PathBuf::from)
        .unwrap_or_else(|_| home.join("AppData").join("Roaming"));
    let localappdata = std::env::var("LOCALAPPDATA")
        .map(PathBuf::from)
        .unwrap_or_else(|_| home.join("AppData").join("Local"));

    let expanded = path
        .replace("${HOME}", &home.to_string_lossy())
        .replace("$HOME", &home.to_string_lossy())
        .replace("~", &home.to_string_lossy())
        .replace("${APPDATA}", &appdata.to_string_lossy())
        .replace("$APPDATA", &appdata.to_string_lossy())
        .replace("${LOCALAPPDATA}", &localappdata.to_string_lossy())
        .replace("$LOCALAPPDATA", &localappdata.to_string_lossy());

    PathBuf::from(expanded)
}

fn find_config_file(explicit: Option<PathBuf>) -> Result<PathBuf> {
    // 1. Explicit path
    if let Some(p) = explicit {
        if p.exists() {
            return Ok(p);
        }
        anyhow::bail!("Config file not found: {}", p.display());
    }

    // 2. Current directory
    let cwd = std::env::current_dir()?;
    let cwd_config = cwd.join("tron.toml");
    if cwd_config.exists() {
        return Ok(cwd_config);
    }

    // 3. Dotfiles repo
    let home = dirs::home_dir().context("Could not find home directory")?;
    let dotfiles = home.join("Projects").join("tron-ares-dotfiles").join("tron.toml");
    if dotfiles.exists() {
        return Ok(dotfiles);
    }

    // 4. ~/.config/tron/tron.toml
    let config_dir = home.join(".config").join("tron").join("tron.toml");
    if config_dir.exists() {
        return Ok(config_dir);
    }

    anyhow::bail!(
        "Could not find tron.toml. Looked in:\n  - {}\n  - {}\n  - {}\n\nRun 'tron init' to create one.",
        cwd_config.display(),
        dotfiles.display(),
        config_dir.display()
    )
}

fn load_config(path: &PathBuf) -> Result<TronConfig> {
    let content = fs::read_to_string(path)
        .with_context(|| format!("Failed to read {}", path.display()))?;
    toml::from_str(&content).context("Failed to parse tron.toml")
}

fn resolve_configs(config: &TronConfig) -> Vec<ResolvedConfig> {
    let repo_base = expand_path(&config.dotfiles.repo_path);

    config
        .config
        .iter()
        .map(|c| ResolvedConfig {
            name: c.name.clone(),
            category: c.category.clone(),
            repo_path: repo_base.join(&c.repo_path),
            system_path: expand_path(&c.system_path),
        })
        .collect()
}

// ============================================================================
// Sync Logic
// ============================================================================

fn file_hash(path: &PathBuf) -> Option<String> {
    fs::read(path).ok().map(|data| {
        let mut hasher = Sha256::new();
        hasher.update(&data);
        hex::encode(hasher.finalize())
    })
}

fn get_sync_status(cfg: &ResolvedConfig) -> SyncStatus {
    let repo_exists = cfg.repo_path.exists();
    let system_exists = cfg.system_path.exists();

    match (repo_exists, system_exists) {
        (false, false) => SyncStatus::BothMissing,
        (false, true) => SyncStatus::RepoMissing,
        (true, false) => SyncStatus::SystemMissing,
        (true, true) => {
            let repo_hash = file_hash(&cfg.repo_path);
            let system_hash = file_hash(&cfg.system_path);

            if repo_hash == system_hash {
                SyncStatus::Synced
            } else {
                // Compare modification times
                let repo_mtime = fs::metadata(&cfg.repo_path)
                    .and_then(|m| m.modified())
                    .ok();
                let system_mtime = fs::metadata(&cfg.system_path)
                    .and_then(|m| m.modified())
                    .ok();

                match (repo_mtime, system_mtime) {
                    (Some(r), Some(s)) if r > s => SyncStatus::RepoNewer,
                    (Some(r), Some(s)) if s > r => SyncStatus::SystemNewer,
                    _ => SyncStatus::Conflict,
                }
            }
        }
    }
}

// ============================================================================
// Commands
// ============================================================================

fn cmd_status(configs: &[ResolvedConfig], category: Option<String>, outdated: bool) -> Result<()> {
    let filtered: Vec<_> = configs
        .iter()
        .filter(|c| category.as_ref().map_or(true, |cat| &c.category == cat))
        .collect();

    let rows: Vec<StatusRow> = filtered
        .iter()
        .filter_map(|cfg| {
            let status = get_sync_status(cfg);
            if outdated && status == SyncStatus::Synced {
                return None;
            }
            Some(StatusRow {
                name: cfg.name.clone(),
                category: cfg.category.clone(),
                status: status.display().to_string(),
            })
        })
        .collect();

    if rows.is_empty() {
        if outdated {
            println!("{}", "All configs are in sync!".green());
        } else {
            println!("{}", "No configs found.".yellow());
        }
    } else {
        let table = Table::new(rows).to_string();
        println!("{}", table);

        let synced = filtered
            .iter()
            .filter(|c| get_sync_status(c) == SyncStatus::Synced)
            .count();
        println!(
            "\n{}/{} configs in sync",
            synced.to_string().green(),
            filtered.len()
        );
    }

    Ok(())
}

fn cmd_list(configs: &[ResolvedConfig], category: Option<String>, json: bool) -> Result<()> {
    let filtered: Vec<_> = configs
        .iter()
        .filter(|c| category.as_ref().map_or(true, |cat| &c.category == cat))
        .collect();

    if json {
        let map: Vec<_> = filtered
            .iter()
            .map(|c| {
                serde_json::json!({
                    "name": c.name,
                    "category": c.category,
                    "repo_path": c.repo_path,
                    "system_path": c.system_path,
                })
            })
            .collect();
        println!("{}", serde_json::to_string_pretty(&map)?);
        return Ok(());
    }

    let rows: Vec<ListRow> = filtered
        .iter()
        .map(|c| ListRow {
            name: c.name.clone(),
            category: c.category.clone(),
            repo_path: c.repo_path.to_string_lossy().chars().take(40).collect(),
            system_path: c.system_path.to_string_lossy().chars().take(40).collect(),
        })
        .collect();

    let table = Table::new(rows).to_string();
    println!("{}", table);
    println!("\n{} configs", filtered.len().to_string().cyan());

    Ok(())
}

fn cmd_deploy(
    configs: &[ResolvedConfig],
    names: Vec<String>,
    category: Option<String>,
    dry_run: bool,
    force: bool,
) -> Result<()> {
    let filtered: Vec<_> = configs
        .iter()
        .filter(|c| {
            if !names.is_empty() {
                names.contains(&c.name)
            } else if let Some(ref cat) = category {
                &c.category == cat
            } else {
                true
            }
        })
        .collect();

    if filtered.is_empty() {
        println!("{}", "No configs matched.".yellow());
        return Ok(());
    }

    for cfg in filtered {
        let status = get_sync_status(cfg);

        // Skip if already synced
        if status == SyncStatus::Synced {
            println!("{} {} (already synced)", "·".white(), cfg.name);
            continue;
        }

        // Check if repo file exists
        if !cfg.repo_path.exists() {
            println!(
                "{} {} (repo file missing: {})",
                "✗".red(),
                cfg.name,
                cfg.repo_path.display()
            );
            continue;
        }

        // Check if system is newer and not forcing
        if status == SyncStatus::SystemNewer && !force {
            println!(
                "{} {} (system newer, use --force to overwrite)",
                "!".yellow(),
                cfg.name
            );
            continue;
        }

        if dry_run {
            println!(
                "{} {} -> {}",
                "→".cyan(),
                cfg.repo_path.display(),
                cfg.system_path.display()
            );
        } else {
            // Create parent directories
            if let Some(parent) = cfg.system_path.parent() {
                fs::create_dir_all(parent)?;
            }

            fs::copy(&cfg.repo_path, &cfg.system_path).with_context(|| {
                format!(
                    "Failed to copy {} to {}",
                    cfg.repo_path.display(),
                    cfg.system_path.display()
                )
            })?;

            println!("{} {}", "✓".green(), cfg.name);
        }
    }

    if dry_run {
        println!("\n{}", "(dry run - no files changed)".yellow());
    }

    Ok(())
}

fn cmd_backup(
    configs: &[ResolvedConfig],
    names: Vec<String>,
    category: Option<String>,
    dry_run: bool,
    force: bool,
) -> Result<()> {
    let filtered: Vec<_> = configs
        .iter()
        .filter(|c| {
            if !names.is_empty() {
                names.contains(&c.name)
            } else if let Some(ref cat) = category {
                &c.category == cat
            } else {
                true
            }
        })
        .collect();

    if filtered.is_empty() {
        println!("{}", "No configs matched.".yellow());
        return Ok(());
    }

    for cfg in filtered {
        let status = get_sync_status(cfg);

        // Skip if already synced
        if status == SyncStatus::Synced {
            println!("{} {} (already synced)", "·".white(), cfg.name);
            continue;
        }

        // Check if system file exists
        if !cfg.system_path.exists() {
            println!(
                "{} {} (system file missing: {})",
                "✗".red(),
                cfg.name,
                cfg.system_path.display()
            );
            continue;
        }

        // Check if repo is newer and not forcing
        if status == SyncStatus::RepoNewer && !force {
            println!(
                "{} {} (repo newer, use --force to overwrite)",
                "!".yellow(),
                cfg.name
            );
            continue;
        }

        if dry_run {
            println!(
                "{} {} <- {}",
                "←".cyan(),
                cfg.repo_path.display(),
                cfg.system_path.display()
            );
        } else {
            // Create parent directories
            if let Some(parent) = cfg.repo_path.parent() {
                fs::create_dir_all(parent)?;
            }

            fs::copy(&cfg.system_path, &cfg.repo_path).with_context(|| {
                format!(
                    "Failed to copy {} to {}",
                    cfg.system_path.display(),
                    cfg.repo_path.display()
                )
            })?;

            println!("{} {}", "✓".green(), cfg.name);
        }
    }

    if dry_run {
        println!("\n{}", "(dry run - no files changed)".yellow());
    }

    Ok(())
}

fn cmd_diff(configs: &[ResolvedConfig], name: &str, reverse: bool) -> Result<()> {
    let cfg = configs
        .iter()
        .find(|c| c.name == name)
        .with_context(|| format!("Config '{}' not found", name))?;

    let (left_path, right_path, left_label, right_label) = if reverse {
        (
            &cfg.system_path,
            &cfg.repo_path,
            "system",
            "repo",
        )
    } else {
        (
            &cfg.repo_path,
            &cfg.system_path,
            "repo",
            "system",
        )
    };

    let left_content = fs::read_to_string(left_path).unwrap_or_else(|_| String::new());
    let right_content = fs::read_to_string(right_path).unwrap_or_else(|_| String::new());

    if left_content == right_content {
        println!("{}", "Files are identical.".green());
        return Ok(());
    }

    println!(
        "{} {} vs {}",
        "Diff:".cyan().bold(),
        format!("{} ({})", left_path.display(), left_label).red(),
        format!("{} ({})", right_path.display(), right_label).green()
    );
    println!();

    let diff = TextDiff::from_lines(&left_content, &right_content);

    for change in diff.iter_all_changes() {
        let line = match change.tag() {
            ChangeTag::Delete => format!("-{}", change).red(),
            ChangeTag::Insert => format!("+{}", change).green(),
            ChangeTag::Equal => format!(" {}", change).white(),
        };
        print!("{}", line);
    }

    Ok(())
}

fn cmd_edit(configs: &[ResolvedConfig], name: &str, system: bool) -> Result<()> {
    let cfg = configs
        .iter()
        .find(|c| c.name == name)
        .with_context(|| format!("Config '{}' not found", name))?;

    let path = if system {
        &cfg.system_path
    } else {
        &cfg.repo_path
    };

    if !path.exists() {
        anyhow::bail!("File does not exist: {}", path.display());
    }

    let editor = std::env::var("EDITOR").unwrap_or_else(|_| "notepad".to_string());
    Command::new(&editor).arg(path).status()?;

    Ok(())
}

fn cmd_show(configs: &[ResolvedConfig], name: &str) -> Result<()> {
    let cfg = configs
        .iter()
        .find(|c| c.name == name)
        .with_context(|| format!("Config '{}' not found", name))?;

    let status = get_sync_status(cfg);

    println!("{}: {}", "Name".cyan(), cfg.name);
    println!("{}: {}", "Category".cyan(), cfg.category);
    println!("{}: {}", "Repo".cyan(), cfg.repo_path.display());
    println!("{}: {}", "System".cyan(), cfg.system_path.display());
    println!("{}: {}", "Status".cyan(), status.display());

    // File info
    if cfg.repo_path.exists() {
        let meta = fs::metadata(&cfg.repo_path)?;
        let size = meta.len();
        println!("{}: {} bytes", "Repo Size".cyan(), size);
    }

    if cfg.system_path.exists() {
        let meta = fs::metadata(&cfg.system_path)?;
        let size = meta.len();
        println!("{}: {} bytes", "System Size".cyan(), size);
    }

    Ok(())
}

fn cmd_open(config: &TronConfig) -> Result<()> {
    let repo_path = expand_path(&config.dotfiles.repo_path);

    #[cfg(target_os = "windows")]
    {
        Command::new("explorer").arg(&repo_path).spawn()?;
    }

    #[cfg(target_os = "macos")]
    {
        Command::new("open").arg(&repo_path).spawn()?;
    }

    #[cfg(target_os = "linux")]
    {
        Command::new("xdg-open").arg(&repo_path).spawn()?;
    }

    println!("Opened: {}", repo_path.display());
    Ok(())
}

fn cmd_mcp(args: Vec<String>) -> Result<()> {
    let home = dirs::home_dir().context("Could not find home directory")?;
    let mcp_bin = home.join("bin").join("mcp.exe");

    if !mcp_bin.exists() {
        anyhow::bail!(
            "mcp CLI not found at {}. Build and install it first.",
            mcp_bin.display()
        );
    }

    let status = Command::new(&mcp_bin).args(&args).status()?;

    std::process::exit(status.code().unwrap_or(1));
}

fn cmd_categories(configs: &[ResolvedConfig]) -> Result<()> {
    let mut categories: HashMap<String, usize> = HashMap::new();

    for cfg in configs {
        *categories.entry(cfg.category.clone()).or_insert(0) += 1;
    }

    let mut sorted: Vec<_> = categories.into_iter().collect();
    sorted.sort_by(|a, b| a.0.cmp(&b.0));

    println!("{}", "Categories:".cyan().bold());
    for (cat, count) in sorted {
        println!("  {} ({})", cat, count);
    }

    Ok(())
}

fn cmd_init(repo: Option<PathBuf>) -> Result<()> {
    let repo_path = repo.unwrap_or_else(|| {
        dirs::home_dir()
            .unwrap_or_else(|| PathBuf::from("."))
            .join("Projects")
            .join("tron-ares-dotfiles")
    });

    let config_path = repo_path.join("tron.toml");

    if config_path.exists() {
        println!(
            "{} {} already exists",
            "!".yellow(),
            config_path.display()
        );
        return Ok(());
    }

    // Create a minimal config
    let template = format!(
        r#"# Tron Ares Dotfiles Configuration

[dotfiles]
repo_path = "{}"

# Add your configs below:
# [[config]]
# name = "example"
# category = "cli"
# repo_path = "example/config.toml"
# system_path = "${{HOME}}/.config/example/config.toml"
"#,
        repo_path.display()
    );

    fs::write(&config_path, template)?;
    println!("{} Created {}", "✓".green(), config_path.display());

    Ok(())
}

fn cmd_completions(shell: Shell) -> Result<()> {
    let mut cmd = Cli::command();
    generate(shell, &mut cmd, "tron", &mut io::stdout());
    Ok(())
}

// ============================================================================
// Main
// ============================================================================

fn main() -> Result<()> {
    let cli = Cli::parse();

    // Handle init specially (doesn't need config file)
    if let Commands::Init { repo } = cli.command {
        return cmd_init(repo);
    }

    // Handle mcp specially (delegates to mcp CLI)
    if let Commands::Mcp { args } = cli.command {
        return cmd_mcp(args);
    }

    // Handle completions specially (doesn't need config file)
    if let Commands::Completions { shell } = cli.command {
        return cmd_completions(shell);
    }

    // Load config
    let config_path = find_config_file(cli.config)?;
    let config = load_config(&config_path)?;
    let configs = resolve_configs(&config);

    match cli.command {
        Commands::Status { category, outdated } => cmd_status(&configs, category, outdated),
        Commands::List { category, json } => cmd_list(&configs, category, json),
        Commands::Deploy {
            names,
            category,
            dry_run,
            force,
        } => cmd_deploy(&configs, names, category, dry_run, force),
        Commands::Backup {
            names,
            category,
            dry_run,
            force,
        } => cmd_backup(&configs, names, category, dry_run, force),
        Commands::Diff { name, reverse } => cmd_diff(&configs, &name, reverse),
        Commands::Edit { name, system } => cmd_edit(&configs, &name, system),
        Commands::Show { name } => cmd_show(&configs, &name),
        Commands::Open => cmd_open(&config),
        Commands::Categories => cmd_categories(&configs),
        Commands::Init { .. } => unreachable!(),
        Commands::Mcp { .. } => unreachable!(),
        Commands::Completions { .. } => unreachable!(),
    }
}
