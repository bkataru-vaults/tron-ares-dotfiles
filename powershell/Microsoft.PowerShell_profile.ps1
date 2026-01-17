# PowerShell 7 Optimized Profile
# Migrated from PS 5.1 with performance improvements

#region Prompt - Starship
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
#endregion

#region PSReadLine - PS7 ships with it, no import needed
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView
#endregion

#region Node.js - fnm (fast node manager)
if (Get-Command fnm -ErrorAction SilentlyContinue) {
    fnm env --use-on-cd --shell power-shell | Out-String | Invoke-Expression
}
#endregion

#region Zoxide - smarter cd
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { zoxide init powershell | Out-String })
}
#endregion

#region Functions
function Get-SystemStats {
    [CmdletBinding()]
    param()
    
    $cpu = (Get-CimInstance Win32_Processor).LoadPercentage
    $os = Get-CimInstance Win32_OperatingSystem
    $memPercent = [math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize) * 100, 1)
    
    $disk = Get-PSDrive C
    $diskPercent = [math]::Round(($disk.Used / ($disk.Used + $disk.Free)) * 100, 1)
    
    [PSCustomObject]@{
        CPU       = "$cpu%"
        Memory    = "$memPercent%"
        Disk      = "$diskPercent%"
        Timestamp = Get-Date -Format "HH:mm:ss"
    }
}
Set-Alias -Name sysinfo -Value Get-SystemStats

# Quick edit functions
function np_hosts { notepad C:\Windows\System32\Drivers\etc\hosts }
function np_profile { notepad $PROFILE }

# Context generation utility
if (Test-Path "C:\Development\scripts\contxtgen.ps1") {
    function contxtgen { & "C:\Development\scripts\contxtgen.ps1" @args }
}
#endregion

#region Modules
Import-Module Terminal-Icons
Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
#endregion

#region Startup info (minimal)
Write-Host "PS7 Ready | sysinfo | np_profile | Ctrl+f: fzf | Ctrl+r: history" -ForegroundColor DarkGray
#endregion
