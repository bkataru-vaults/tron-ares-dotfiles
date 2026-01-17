#Requires -Version 7.0
<#
.SYNOPSIS
    MCP Universal Runner - PowerShell version
.DESCRIPTION
    Supports Node (fnm), Bun, Deno, npx, bunx runtimes
.PARAMETER Spec
    Runtime specification in format "runtime:path" or just "path" (defaults to node)
.EXAMPLE
    mcp-run.ps1 node:@upstash/context7-mcp/dist/index.js
    mcp-run.ps1 bun:some-package/index.js
    mcp-run.ps1 npx:@modelcontextprotocol/server-filesystem /path/to/dir
#>

param(
    [Parameter(Mandatory, Position = 0)]
    [string]$Spec,
    
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$Arguments
)

$ErrorActionPreference = 'Stop'
$McpDir = $PSScriptRoot

# Load environment variables from .env
$EnvFile = Join-Path $McpDir '.env'
if (Test-Path $EnvFile) {
    Get-Content $EnvFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
            [Environment]::SetEnvironmentVariable($Matches[1].Trim(), $Matches[2].Trim(), 'Process')
        }
    }
}

# Parse runtime:path specification
if ($Spec -match '^([^:]+):(.+)$') {
    $Runtime = $Matches[1].ToLower()
    $Target = $Matches[2]
} else {
    # Backward compatibility: no prefix means node
    $Runtime = 'node'
    $Target = $Spec
}

# Runtime handlers
switch ($Runtime) {
    'node' {
        $FnmDir = Join-Path $env:USERPROFILE 'AppData\Roaming\fnm'
        $NodePath = Join-Path $FnmDir 'aliases\default'
        $NodeModules = Join-Path $NodePath 'node_modules'
        $env:PATH = "$NodePath;$env:PATH"
        
        $ScriptPath = Join-Path $NodeModules $Target
        & node $ScriptPath @Arguments
    }
    
    'bun' {
        $BunModules = Join-Path $env:USERPROFILE '.bun\install\global\node_modules'
        $ScriptPath = Join-Path $BunModules $Target
        & bun run $ScriptPath @Arguments
    }
    
    'deno' {
        & deno run --allow-all $Target @Arguments
    }
    
    'npx' {
        $FnmDir = Join-Path $env:USERPROFILE 'AppData\Roaming\fnm'
        $NodePath = Join-Path $FnmDir 'aliases\default'
        $env:PATH = "$NodePath;$env:PATH"
        
        & npx -y $Target @Arguments
    }
    
    'bunx' {
        & bunx $Target @Arguments
    }
    
    default {
        Write-Error "[mcp-run] Unknown runtime: $Runtime"
        exit 1
    }
}

exit $LASTEXITCODE
