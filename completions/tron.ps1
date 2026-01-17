
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

Register-ArgumentCompleter -Native -CommandName 'tron' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $commandElements = $commandAst.CommandElements
    $command = @(
        'tron'
        for ($i = 1; $i -lt $commandElements.Count; $i++) {
            $element = $commandElements[$i]
            if ($element -isnot [StringConstantExpressionAst] -or
                $element.StringConstantType -ne [StringConstantType]::BareWord -or
                $element.Value.StartsWith('-') -or
                $element.Value -eq $wordToComplete) {
                break
        }
        $element.Value
    }) -join ';'

    $completions = @(switch ($command) {
        'tron' {
            [CompletionResult]::new('--config', '--config', [CompletionResultType]::ParameterName, 'Path to tron.toml config file')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('status', 'status', [CompletionResultType]::ParameterValue, 'Show sync status of all configs')
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List all managed configs')
            [CompletionResult]::new('deploy', 'deploy', [CompletionResultType]::ParameterValue, 'Deploy configs from repo to system')
            [CompletionResult]::new('backup', 'backup', [CompletionResultType]::ParameterValue, 'Backup configs from system to repo')
            [CompletionResult]::new('diff', 'diff', [CompletionResultType]::ParameterValue, 'Show diff between repo and system')
            [CompletionResult]::new('edit', 'edit', [CompletionResultType]::ParameterValue, 'Edit a config file')
            [CompletionResult]::new('show', 'show', [CompletionResultType]::ParameterValue, 'Show config paths')
            [CompletionResult]::new('open', 'open', [CompletionResultType]::ParameterValue, 'Open dotfiles repo in file manager')
            [CompletionResult]::new('mcp', 'mcp', [CompletionResultType]::ParameterValue, 'Run MCP subcommand (delegates to mcp CLI)')
            [CompletionResult]::new('categories', 'categories', [CompletionResultType]::ParameterValue, 'Show categories')
            [CompletionResult]::new('init', 'init', [CompletionResultType]::ParameterValue, 'Initialize tron.toml in dotfiles repo')
            [CompletionResult]::new('completions', 'completions', [CompletionResultType]::ParameterValue, 'Generate shell completions')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'tron;status' {
            [CompletionResult]::new('-c', '-c', [CompletionResultType]::ParameterName, 'Filter by category')
            [CompletionResult]::new('--category', '--category', [CompletionResultType]::ParameterName, 'Filter by category')
            [CompletionResult]::new('--config', '--config', [CompletionResultType]::ParameterName, 'Path to tron.toml config file')
            [CompletionResult]::new('-o', '-o', [CompletionResultType]::ParameterName, 'Show only out-of-sync configs')
            [CompletionResult]::new('--outdated', '--outdated', [CompletionResultType]::ParameterName, 'Show only out-of-sync configs')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'tron;list' {
            [CompletionResult]::new('-c', '-c', [CompletionResultType]::ParameterName, 'Filter by category')
            [CompletionResult]::new('--category', '--category', [CompletionResultType]::ParameterName, 'Filter by category')
            [CompletionResult]::new('--config', '--config', [CompletionResultType]::ParameterName, 'Path to tron.toml config file')
            [CompletionResult]::new('--json', '--json', [CompletionResultType]::ParameterName, 'Output as JSON')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'tron;deploy' {
            [CompletionResult]::new('-c', '-c', [CompletionResultType]::ParameterName, 'Deploy entire category')
            [CompletionResult]::new('--category', '--category', [CompletionResultType]::ParameterName, 'Deploy entire category')
            [CompletionResult]::new('--config', '--config', [CompletionResultType]::ParameterName, 'Path to tron.toml config file')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Dry run - show what would be deployed')
            [CompletionResult]::new('--dry-run', '--dry-run', [CompletionResultType]::ParameterName, 'Dry run - show what would be deployed')
            [CompletionResult]::new('-f', '-f', [CompletionResultType]::ParameterName, 'Force overwrite even if system file is newer')
            [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Force overwrite even if system file is newer')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'tron;backup' {
            [CompletionResult]::new('-c', '-c', [CompletionResultType]::ParameterName, 'Backup entire category')
            [CompletionResult]::new('--category', '--category', [CompletionResultType]::ParameterName, 'Backup entire category')
            [CompletionResult]::new('--config', '--config', [CompletionResultType]::ParameterName, 'Path to tron.toml config file')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Dry run - show what would be backed up')
            [CompletionResult]::new('--dry-run', '--dry-run', [CompletionResultType]::ParameterName, 'Dry run - show what would be backed up')
            [CompletionResult]::new('-f', '-f', [CompletionResultType]::ParameterName, 'Force overwrite even if repo file is newer')
            [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Force overwrite even if repo file is newer')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'tron;diff' {
            [CompletionResult]::new('--config', '--config', [CompletionResultType]::ParameterName, 'Path to tron.toml config file')
            [CompletionResult]::new('-r', '-r', [CompletionResultType]::ParameterName, 'Show system -> repo diff (default is repo -> system)')
            [CompletionResult]::new('--reverse', '--reverse', [CompletionResultType]::ParameterName, 'Show system -> repo diff (default is repo -> system)')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'tron;edit' {
            [CompletionResult]::new('--config', '--config', [CompletionResultType]::ParameterName, 'Path to tron.toml config file')
            [CompletionResult]::new('-s', '-s', [CompletionResultType]::ParameterName, 'Edit system file instead of repo file')
            [CompletionResult]::new('--system', '--system', [CompletionResultType]::ParameterName, 'Edit system file instead of repo file')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'tron;show' {
            [CompletionResult]::new('--config', '--config', [CompletionResultType]::ParameterName, 'Path to tron.toml config file')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'tron;open' {
            [CompletionResult]::new('--config', '--config', [CompletionResultType]::ParameterName, 'Path to tron.toml config file')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'tron;mcp' {
            [CompletionResult]::new('--config', '--config', [CompletionResultType]::ParameterName, 'Path to tron.toml config file')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'tron;categories' {
            [CompletionResult]::new('--config', '--config', [CompletionResultType]::ParameterName, 'Path to tron.toml config file')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'tron;init' {
            [CompletionResult]::new('-r', '-r', [CompletionResultType]::ParameterName, 'Path to dotfiles repo')
            [CompletionResult]::new('--repo', '--repo', [CompletionResultType]::ParameterName, 'Path to dotfiles repo')
            [CompletionResult]::new('--config', '--config', [CompletionResultType]::ParameterName, 'Path to tron.toml config file')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'tron;completions' {
            [CompletionResult]::new('--config', '--config', [CompletionResultType]::ParameterName, 'Path to tron.toml config file')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'tron;help' {
            [CompletionResult]::new('status', 'status', [CompletionResultType]::ParameterValue, 'Show sync status of all configs')
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List all managed configs')
            [CompletionResult]::new('deploy', 'deploy', [CompletionResultType]::ParameterValue, 'Deploy configs from repo to system')
            [CompletionResult]::new('backup', 'backup', [CompletionResultType]::ParameterValue, 'Backup configs from system to repo')
            [CompletionResult]::new('diff', 'diff', [CompletionResultType]::ParameterValue, 'Show diff between repo and system')
            [CompletionResult]::new('edit', 'edit', [CompletionResultType]::ParameterValue, 'Edit a config file')
            [CompletionResult]::new('show', 'show', [CompletionResultType]::ParameterValue, 'Show config paths')
            [CompletionResult]::new('open', 'open', [CompletionResultType]::ParameterValue, 'Open dotfiles repo in file manager')
            [CompletionResult]::new('mcp', 'mcp', [CompletionResultType]::ParameterValue, 'Run MCP subcommand (delegates to mcp CLI)')
            [CompletionResult]::new('categories', 'categories', [CompletionResultType]::ParameterValue, 'Show categories')
            [CompletionResult]::new('init', 'init', [CompletionResultType]::ParameterValue, 'Initialize tron.toml in dotfiles repo')
            [CompletionResult]::new('completions', 'completions', [CompletionResultType]::ParameterValue, 'Generate shell completions')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'tron;help;status' {
            break
        }
        'tron;help;list' {
            break
        }
        'tron;help;deploy' {
            break
        }
        'tron;help;backup' {
            break
        }
        'tron;help;diff' {
            break
        }
        'tron;help;edit' {
            break
        }
        'tron;help;show' {
            break
        }
        'tron;help;open' {
            break
        }
        'tron;help;mcp' {
            break
        }
        'tron;help;categories' {
            break
        }
        'tron;help;init' {
            break
        }
        'tron;help;completions' {
            break
        }
        'tron;help;help' {
            break
        }
    })

    $completions.Where{ $_.CompletionText -like "$wordToComplete*" } |
        Sort-Object -Property ListItemText
}
