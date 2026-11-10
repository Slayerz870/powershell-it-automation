#requires -Version 5.1
<#
.SYNOPSIS
    Collects a read-only health snapshot from the local Windows workstation.
.DESCRIPTION
    Returns a structured object with OS, uptime, RAM, fixed disk free space,
    and pending-reboot indicators. No configuration changes are made.
.EXAMPLE
    .\Get-WorkstationHealth.ps1 | ConvertTo-Json -Depth 5
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
if (-not $IsWindows -and $PSVersionTable.PSEdition -eq 'Core') {
    throw 'This script requires Windows.'
}

$os = Get-CimInstance -ClassName Win32_OperatingSystem
$computer = Get-CimInstance -ClassName Win32_ComputerSystem
$disks = @(Get-CimInstance -ClassName Win32_LogicalDisk -Filter 'DriveType=3' |
    ForEach-Object {
        [pscustomobject]@{
            Drive = $_.DeviceID
            SizeGB = [math]::Round($_.Size / 1GB, 2)
            FreeGB = [math]::Round($_.FreeSpace / 1GB, 2)
            FreePercent = if ($_.Size -gt 0) { [math]::Round(100 * $_.FreeSpace / $_.Size, 1) } else { $null }
        }
    })

$rebootPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending',
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
)
$rebootIndicators = @($rebootPaths | Where-Object { Test-Path $_ })
$sessionManager = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue
if ($null -ne $sessionManager -and $null -ne $sessionManager.PendingFileRenameOperations) {
    $rebootIndicators += 'PendingFileRenameOperations'
}

[pscustomobject]@{
    ComputerName = $env:COMPUTERNAME
    CollectedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
    OS = $os.Caption
    OSVersion = $os.Version
    LastBootTime = $os.LastBootUpTime
    UptimeDays = [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalDays, 2)
    TotalRAMGB = [math]::Round($computer.TotalPhysicalMemory / 1GB, 2)
    FixedDisks = $disks
    PendingReboot = ($rebootIndicators.Count -gt 0)
    RebootIndicators = $rebootIndicators
}
