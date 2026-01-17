
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

Register-ArgumentCompleter -Native -CommandName 'mcp' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $commandElements = $commandAst.CommandElements
    $command = @(
        'mcp'
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
        'mcp' {
            [CompletionResult]::new('--mcp-dir', '--mcp-dir', [CompletionResultType]::ParameterName, 'Path to MCP directory (default: ~/.mcp)')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List all configured MCP servers')
            [CompletionResult]::new('run', 'run', [CompletionResultType]::ParameterValue, 'Run an MCP server')
            [CompletionResult]::new('gen', 'gen', [CompletionResultType]::ParameterValue, 'Generate Cursor and OpenCode configuration files')
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add a new MCP server')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove an MCP server')
            [CompletionResult]::new('enable', 'enable', [CompletionResultType]::ParameterValue, 'Enable an MCP server')
            [CompletionResult]::new('disable', 'disable', [CompletionResultType]::ParameterValue, 'Disable an MCP server')
            [CompletionResult]::new('show', 'show', [CompletionResultType]::ParameterValue, 'Show server details')
            [CompletionResult]::new('env', 'env', [CompletionResultType]::ParameterValue, 'Manage environment variables')
            [CompletionResult]::new('info', 'info', [CompletionResultType]::ParameterValue, 'Show paths and configuration')
            [CompletionResult]::new('completions', 'completions', [CompletionResultType]::ParameterValue, 'Generate shell completions')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'mcp;list' {
            [CompletionResult]::new('--mcp-dir', '--mcp-dir', [CompletionResultType]::ParameterName, 'Path to MCP directory (default: ~/.mcp)')
            [CompletionResult]::new('-e', '-e', [CompletionResultType]::ParameterName, 'Show only enabled servers')
            [CompletionResult]::new('--enabled', '--enabled', [CompletionResultType]::ParameterName, 'Show only enabled servers')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Show only disabled servers')
            [CompletionResult]::new('--disabled', '--disabled', [CompletionResultType]::ParameterName, 'Show only disabled servers')
            [CompletionResult]::new('--json', '--json', [CompletionResultType]::ParameterName, 'Output as JSON')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'mcp;run' {
            [CompletionResult]::new('--mcp-dir', '--mcp-dir', [CompletionResultType]::ParameterName, 'Path to MCP directory (default: ~/.mcp)')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'mcp;gen' {
            [CompletionResult]::new('--mcp-dir', '--mcp-dir', [CompletionResultType]::ParameterName, 'Path to MCP directory (default: ~/.mcp)')
            [CompletionResult]::new('--cursor', '--cursor', [CompletionResultType]::ParameterName, 'Only generate Cursor config')
            [CompletionResult]::new('--opencode', '--opencode', [CompletionResultType]::ParameterName, 'Only generate OpenCode config')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Dry run - print configs without writing')
            [CompletionResult]::new('--dry-run', '--dry-run', [CompletionResultType]::ParameterName, 'Dry run - print configs without writing')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'mcp;add' {
            [CompletionResult]::new('-r', '-r', [CompletionResultType]::ParameterName, 'Runtime (node, bun, deno, npx, bunx)')
            [CompletionResult]::new('--runtime', '--runtime', [CompletionResultType]::ParameterName, 'Runtime (node, bun, deno, npx, bunx)')
            [CompletionResult]::new('-p', '-p', [CompletionResultType]::ParameterName, 'Path to server entry point')
            [CompletionResult]::new('--path', '--path', [CompletionResultType]::ParameterName, 'Path to server entry point')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Description')
            [CompletionResult]::new('--description', '--description', [CompletionResultType]::ParameterName, 'Description')
            [CompletionResult]::new('-t', '-t', [CompletionResultType]::ParameterName, 'Tool names (comma-separated)')
            [CompletionResult]::new('--tools', '--tools', [CompletionResultType]::ParameterName, 'Tool names (comma-separated)')
            [CompletionResult]::new('-e', '-e', [CompletionResultType]::ParameterName, 'Environment variables required (comma-separated)')
            [CompletionResult]::new('--env', '--env', [CompletionResultType]::ParameterName, 'Environment variables required (comma-separated)')
            [CompletionResult]::new('--mcp-dir', '--mcp-dir', [CompletionResultType]::ParameterName, 'Path to MCP directory (default: ~/.mcp)')
            [CompletionResult]::new('--disabled', '--disabled', [CompletionResultType]::ParameterName, 'Mark as disabled')
            [CompletionResult]::new('--opencode-only', '--opencode-only', [CompletionResultType]::ParameterName, 'Mark as OpenCode-only')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'mcp;remove' {
            [CompletionResult]::new('--mcp-dir', '--mcp-dir', [CompletionResultType]::ParameterName, 'Path to MCP directory (default: ~/.mcp)')
            [CompletionResult]::new('-f', '-f', [CompletionResultType]::ParameterName, 'Skip confirmation')
            [CompletionResult]::new('--force', '--force', [CompletionResultType]::ParameterName, 'Skip confirmation')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'mcp;enable' {
            [CompletionResult]::new('--mcp-dir', '--mcp-dir', [CompletionResultType]::ParameterName, 'Path to MCP directory (default: ~/.mcp)')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'mcp;disable' {
            [CompletionResult]::new('--mcp-dir', '--mcp-dir', [CompletionResultType]::ParameterName, 'Path to MCP directory (default: ~/.mcp)')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'mcp;show' {
            [CompletionResult]::new('--mcp-dir', '--mcp-dir', [CompletionResultType]::ParameterName, 'Path to MCP directory (default: ~/.mcp)')
            [CompletionResult]::new('--json', '--json', [CompletionResultType]::ParameterName, 'Output as JSON')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'mcp;env' {
            [CompletionResult]::new('--mcp-dir', '--mcp-dir', [CompletionResultType]::ParameterName, 'Path to MCP directory (default: ~/.mcp)')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List environment variables')
            [CompletionResult]::new('set', 'set', [CompletionResultType]::ParameterValue, 'Set an environment variable')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove an environment variable')
            [CompletionResult]::new('edit', 'edit', [CompletionResultType]::ParameterValue, 'Edit .env file in default editor')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'mcp;env;list' {
            [CompletionResult]::new('--mcp-dir', '--mcp-dir', [CompletionResultType]::ParameterName, 'Path to MCP directory (default: ~/.mcp)')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'mcp;env;set' {
            [CompletionResult]::new('--mcp-dir', '--mcp-dir', [CompletionResultType]::ParameterName, 'Path to MCP directory (default: ~/.mcp)')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'mcp;env;remove' {
            [CompletionResult]::new('--mcp-dir', '--mcp-dir', [CompletionResultType]::ParameterName, 'Path to MCP directory (default: ~/.mcp)')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'mcp;env;edit' {
            [CompletionResult]::new('--mcp-dir', '--mcp-dir', [CompletionResultType]::ParameterName, 'Path to MCP directory (default: ~/.mcp)')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'mcp;env;help' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List environment variables')
            [CompletionResult]::new('set', 'set', [CompletionResultType]::ParameterValue, 'Set an environment variable')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove an environment variable')
            [CompletionResult]::new('edit', 'edit', [CompletionResultType]::ParameterValue, 'Edit .env file in default editor')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'mcp;env;help;list' {
            break
        }
        'mcp;env;help;set' {
            break
        }
        'mcp;env;help;remove' {
            break
        }
        'mcp;env;help;edit' {
            break
        }
        'mcp;env;help;help' {
            break
        }
        'mcp;info' {
            [CompletionResult]::new('--mcp-dir', '--mcp-dir', [CompletionResultType]::ParameterName, 'Path to MCP directory (default: ~/.mcp)')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'mcp;completions' {
            [CompletionResult]::new('--mcp-dir', '--mcp-dir', [CompletionResultType]::ParameterName, 'Path to MCP directory (default: ~/.mcp)')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            break
        }
        'mcp;help' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List all configured MCP servers')
            [CompletionResult]::new('run', 'run', [CompletionResultType]::ParameterValue, 'Run an MCP server')
            [CompletionResult]::new('gen', 'gen', [CompletionResultType]::ParameterValue, 'Generate Cursor and OpenCode configuration files')
            [CompletionResult]::new('add', 'add', [CompletionResultType]::ParameterValue, 'Add a new MCP server')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove an MCP server')
            [CompletionResult]::new('enable', 'enable', [CompletionResultType]::ParameterValue, 'Enable an MCP server')
            [CompletionResult]::new('disable', 'disable', [CompletionResultType]::ParameterValue, 'Disable an MCP server')
            [CompletionResult]::new('show', 'show', [CompletionResultType]::ParameterValue, 'Show server details')
            [CompletionResult]::new('env', 'env', [CompletionResultType]::ParameterValue, 'Manage environment variables')
            [CompletionResult]::new('info', 'info', [CompletionResultType]::ParameterValue, 'Show paths and configuration')
            [CompletionResult]::new('completions', 'completions', [CompletionResultType]::ParameterValue, 'Generate shell completions')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'mcp;help;list' {
            break
        }
        'mcp;help;run' {
            break
        }
        'mcp;help;gen' {
            break
        }
        'mcp;help;add' {
            break
        }
        'mcp;help;remove' {
            break
        }
        'mcp;help;enable' {
            break
        }
        'mcp;help;disable' {
            break
        }
        'mcp;help;show' {
            break
        }
        'mcp;help;env' {
            [CompletionResult]::new('list', 'list', [CompletionResultType]::ParameterValue, 'List environment variables')
            [CompletionResult]::new('set', 'set', [CompletionResultType]::ParameterValue, 'Set an environment variable')
            [CompletionResult]::new('remove', 'remove', [CompletionResultType]::ParameterValue, 'Remove an environment variable')
            [CompletionResult]::new('edit', 'edit', [CompletionResultType]::ParameterValue, 'Edit .env file in default editor')
            break
        }
        'mcp;help;env;list' {
            break
        }
        'mcp;help;env;set' {
            break
        }
        'mcp;help;env;remove' {
            break
        }
        'mcp;help;env;edit' {
            break
        }
        'mcp;help;info' {
            break
        }
        'mcp;help;completions' {
            break
        }
        'mcp;help;help' {
            break
        }
    })

    $completions.Where{ $_.CompletionText -like "$wordToComplete*" } |
        Sort-Object -Property ListItemText
}
