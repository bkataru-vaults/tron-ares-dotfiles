@echo off
setlocal enabledelayedexpansion

:: ============================================================================
:: MCP Universal Runner - Supports Node (fnm), Bun, Deno, npx, bunx
:: Usage: mcp-run.cmd <runtime:path> [args...]
::   node:@pkg/path.js   - Run via fnm Node
::   bun:@pkg/path.js    - Run via Bun
::   deno:jsr:@pkg       - Run via Deno
::   npx:@pkg            - Auto-install and run via npx
::   bunx:@pkg           - Auto-install and run via bunx
:: ============================================================================

set "MCP_DIR=%~dp0"
set "MCP_DIR=%MCP_DIR:~0,-1%"

:: Load environment variables from .env if it exists
if exist "%MCP_DIR%\.env" (
    for /f "usebackq tokens=1,* delims==" %%a in ("%MCP_DIR%\.env") do (
        set "line=%%a"
        if not "!line:~0,1!"=="#" if not "!line!"=="" (
            set "%%a=%%b"
        )
    )
)

:: Parse runtime:path specification
set "SPEC=%~1"
shift

:: Extract runtime prefix (everything before first colon)
:: and target path (everything after first colon)
set "RUNTIME="
set "TARGET="

:: Find position of first colon using substitution
set "CHECK=!SPEC:~0,5!"
if "!CHECK!"=="node:" (
    set "RUNTIME=node"
    set "TARGET=!SPEC:~5!"
    goto parsed
)
if "!CHECK!"=="deno:" (
    set "RUNTIME=deno"
    set "TARGET=!SPEC:~5!"
    goto parsed
)
if "!CHECK!"=="bunx:" (
    set "RUNTIME=bunx"
    set "TARGET=!SPEC:~5!"
    goto parsed
)
set "CHECK=!SPEC:~0,4!"
if "!CHECK!"=="bun:" (
    set "RUNTIME=bun"
    set "TARGET=!SPEC:~4!"
    goto parsed
)
if "!CHECK!"=="npx:" (
    set "RUNTIME=npx"
    set "TARGET=!SPEC:~4!"
    goto parsed
)

:: No prefix found - assume node runtime (backward compatibility)
set "RUNTIME=node"
set "TARGET=!SPEC!"

:parsed

:: Build remaining args
set "ARGS="
:argloop
if "%~1"=="" goto endargs
set "ARGS=!ARGS! %1"
shift
goto argloop
:endargs

:: Route to appropriate runtime
if /i "!RUNTIME!"=="node" goto run_node
if /i "!RUNTIME!"=="bun" goto run_bun
if /i "!RUNTIME!"=="deno" goto run_deno
if /i "!RUNTIME!"=="npx" goto run_npx
if /i "!RUNTIME!"=="bunx" goto run_bunx

echo [mcp-run] Unknown runtime: !RUNTIME! 1>&2
exit /b 1

:: ----------------------------------------------------------------------------
:run_node
:: Setup fnm environment
set "FNM_DIR=%USERPROFILE%\AppData\Roaming\fnm"
set "FNM_MULTISHELL_PATH=!FNM_DIR!\aliases\default"
set "PATH=!FNM_MULTISHELL_PATH!;!PATH!"
set "NODE_MODULES=!FNM_MULTISHELL_PATH!\node_modules"

:: Run node with the package path
node "!NODE_MODULES!\!TARGET!" !ARGS!
exit /b !errorlevel!

:: ----------------------------------------------------------------------------
:run_bun
:: Bun global modules location
set "BUN_MODULES=%USERPROFILE%\.bun\install\global\node_modules"

bun run "!BUN_MODULES!\!TARGET!" !ARGS!
exit /b !errorlevel!

:: ----------------------------------------------------------------------------
:run_deno
:: Deno runs directly with permissions
deno run --allow-all !TARGET! !ARGS!
exit /b !errorlevel!

:: ----------------------------------------------------------------------------
:run_npx
:: npx auto-installs if needed
set "FNM_DIR=%USERPROFILE%\AppData\Roaming\fnm"
set "FNM_MULTISHELL_PATH=!FNM_DIR!\aliases\default"
set "PATH=!FNM_MULTISHELL_PATH!;!PATH!"

npx -y !TARGET! !ARGS!
exit /b !errorlevel!

:: ----------------------------------------------------------------------------
:run_bunx
bunx !TARGET! !ARGS!
exit /b !errorlevel!
