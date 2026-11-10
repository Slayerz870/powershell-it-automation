
#requires -Version 5.1
<#
.SYNOPSIS
    Collects a read-only Windows workstation health snapshot.
.DESCRIPTION
    Reports operating system, uptime, memory, fixed disks,
    and pending reboot indicators without changing settings.
.EXAMPLE
    .\Get-WorkstationHealth.ps1 | Format-List
.EXAMPLE
    .\Get-WorkstationHealth.ps1 | ConvertTo-Json -Depth 5
#>

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

if ($PSVersionTable.PSEdition -eq 'Core' -and -not $IsWindows) {
    throw 'This script requires Windows.'
}

# Operating system and hardware information
$os = Get-CimInstance -ClassName Win32_OperatingSystem
$computer = Get-CimInstance -ClassName Win32_ComputerSystem

# Normalize boot time to UTC
$nowUtc = [DateTime]::UtcNow
$bootUtc = $os.LastBootUpTime.ToUniversalTime()
$uptime = $nowUtc - $bootUtc

# Guard against invalid or future boot timestamps
$uptimeDays = if ($uptime.TotalSeconds -ge 0) {
    [math]::Round($uptime.TotalDays, 2)
} else {
    $null
}

# Fixed disk information
$disks = @(
    Get-CimInstance -ClassName Win32_LogicalDisk -Filter 'DriveType=3' |
    ForEach-Object {
        $disk = $_

        if ($null -ne $disk.Size -and $disk.Size -gt 0) {
            [pscustomobject]@{
                Drive       = $disk.DeviceID
                SizeGB      = [math]::Round($disk.Size / 1GB, 2)
                FreeGB      = [math]::Round($disk.FreeSpace / 1GB, 2)
                FreePercent = [math]::Round(
                    100 * $disk.FreeSpace / $disk.Size, 1
                )
                Status      = 'Available'
            }
        }
        else {
            [pscustomobject]@{
                Drive       = $disk.DeviceID
                SizeGB      = $null
                FreeGB      = $null
                FreePercent = $null
                Status      = 'Capacity unavailable'
            }
        }
    }
)

# Pending reboot indicators
$rebootPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending',
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
)

$rebootIndicators = @(
    $rebootPaths | Where-Object { Test-Path $_ }
)

$sessionManager = Get-ItemProperty `
    -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' `
    -Name PendingFileRenameOperations `
    -ErrorAction SilentlyContinue

if ($null -ne $sessionManager -and
    $null -ne $sessionManager.PendingFileRenameOperations) {
    $rebootIndicators += 'PendingFileRenameOperations'
}

# Structured health report
[pscustomobject]@{
    ComputerName     = $env:COMPUTERNAME
    CollectedAtUtc   = $nowUtc.ToString('o')
    OS               = $os.Caption
    OSVersion        = $os.Version
    LastBootTime     = $os.LastBootUpTime
    UptimeDays       = $uptimeDays
    TotalRAMGB       = [math]::Round(
        $computer.TotalPhysicalMemory / 1GB, 2
    )
    FixedDisks       = $disks
    PendingReboot    = ($rebootIndicators.Count -gt 0)
    RebootIndicators = $rebootIndicators
}
