#Requires -Version 7.0
<#
.SYNOPSIS
    Generate MCP configuration files for Cursor and OpenCode from servers.json
.DESCRIPTION
    Reads the canonical servers.json and generates vendor-specific config files
.PARAMETER DryRun
    Show what would be generated without writing files
#>

param(
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$McpDir = $PSScriptRoot
$ServersFile = Join-Path $McpDir 'servers.json'
$McpRunCmd = Join-Path $McpDir 'mcp-run.cmd'

# Output paths
$CursorConfig = Join-Path $env:USERPROFILE '.cursor\mcp.json'
$OpenCodeConfig = Join-Path $env:USERPROFILE '.config\opencode\opencode.json'

# Load servers.json
$Config = Get-Content $ServersFile -Raw | ConvertFrom-Json
$Servers = $Config.servers

# Helper: Build command args for a server
function Get-McpCommand {
    param($Name, $Server)
    
    $Runtime = $Server.runtime ?? 'node'
    $Path = $Server.path
    $ExtraArgs = @($Server.args | Where-Object { $_ })
    
    # Build the runtime:path spec
    $Spec = "${Runtime}:${Path}"
    
    @(
        'cmd.exe',
        '/c',
        $McpRunCmd,
        $Spec
    ) + $ExtraArgs
}

# ============================================================================
# Generate Cursor config
# ============================================================================
function New-CursorConfig {
    $McpServers = [ordered]@{}
    
    foreach ($Name in ($Servers.PSObject.Properties.Name | Sort-Object)) {
        $Server = $Servers.$Name
        
        # Skip OpenCode-only servers
        if ($Server.opencode_only) { continue }
        
        $Entry = [ordered]@{
            disabled = [bool]$Server.disabled
        }
        
        if ($Server.type -eq 'remote') {
            # Remote SSE server
            $Entry['url'] = $Server.url
        }
        elseif ($Server.type -eq 'native') {
            # Native binary
            $Entry['command'] = $Server.command
            $Entry['args'] = @($Server.args)
        }
        else {
            # Node/Bun/Deno via mcp-run
            $Cmd = Get-McpCommand -Name $Name -Server $Server
            $Entry['command'] = $Cmd[0]
            $Entry['args'] = @($Cmd[1..($Cmd.Length - 1)])
        }
        
        # Add alwaysAllow if tools defined
        if ($Server.tools -and $Server.tools.Count -gt 0) {
            $Entry['alwaysAllow'] = @($Server.tools)
        } else {
            $Entry['alwaysAllow'] = @()
        }
        
        $McpServers[$Name] = $Entry
    }
    
    @{ mcpServers = $McpServers }
}

# ============================================================================
# Generate OpenCode config
# ============================================================================
function New-OpenCodeConfig {
    $Mcp = [ordered]@{}
    
    foreach ($Name in ($Servers.PSObject.Properties.Name | Sort-Object)) {
        $Server = $Servers.$Name
        
        $Entry = [ordered]@{}
        
        if ($Server.type -eq 'remote') {
            $Entry['type'] = 'remote'
            $Entry['url'] = $Server.url
        }
        elseif ($Server.type -eq 'native') {
            $Entry['type'] = 'local'
            $Entry['command'] = @($Server.command) + @($Server.args)
        }
        else {
            # Node/Bun/Deno via mcp-run
            $Cmd = Get-McpCommand -Name $Name -Server $Server
            $Entry['type'] = 'local'
            $Entry['command'] = $Cmd
        }
        
        $Mcp[$Name] = $Entry
    }
    
    [ordered]@{
        mcp = $Mcp
        '$schema' = 'https://opencode.ai/config.json'
    }
}

# ============================================================================
# Main
# ============================================================================
Write-Host "Reading: $ServersFile" -ForegroundColor Cyan
Write-Host "Found $($Servers.PSObject.Properties.Name.Count) servers" -ForegroundColor Green

# Generate configs
$CursorData = New-CursorConfig
$OpenCodeData = New-OpenCodeConfig

# Convert to JSON
$CursorJson = $CursorData | ConvertTo-Json -Depth 10
$OpenCodeJson = $OpenCodeData | ConvertTo-Json -Depth 10

if ($DryRun) {
    Write-Host "`n=== Cursor Config ===" -ForegroundColor Yellow
    Write-Host $CursorJson
    Write-Host "`n=== OpenCode Config ===" -ForegroundColor Yellow
    Write-Host $OpenCodeJson
}
else {
    # Ensure directories exist
    $CursorDir = Split-Path $CursorConfig
    $OpenCodeDir = Split-Path $OpenCodeConfig
    
    if (-not (Test-Path $CursorDir)) { New-Item -ItemType Directory -Path $CursorDir -Force | Out-Null }
    if (-not (Test-Path $OpenCodeDir)) { New-Item -ItemType Directory -Path $OpenCodeDir -Force | Out-Null }
    
    # Write files
    $CursorJson | Set-Content $CursorConfig -Encoding UTF8
    Write-Host "Wrote: $CursorConfig" -ForegroundColor Green
    
    $OpenCodeJson | Set-Content $OpenCodeConfig -Encoding UTF8
    Write-Host "Wrote: $OpenCodeConfig" -ForegroundColor Green
}

Write-Host "`nDone!" -ForegroundColor Cyan
