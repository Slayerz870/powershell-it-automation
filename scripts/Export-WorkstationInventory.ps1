#requires -Version 5.1
<#
.SYNOPSIS
    Exports local Windows hardware and OS inventory to CSV.
.EXAMPLE
    .\Export-WorkstationInventory.ps1 -Path .\inventory.csv
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Path
)
$ErrorActionPreference = 'Stop'
if (-not $IsWindows -and $PSVersionTable.PSEdition -eq 'Core') { throw 'Windows is required.' }
$computer = Get-CimInstance Win32_ComputerSystem
$bios = Get-CimInstance Win32_BIOS
$os = Get-CimInstance Win32_OperatingSystem
$processor = Get-CimInstance Win32_Processor | Select-Object -First 1
$record = [pscustomobject]@{
    ComputerName = $env:COMPUTERNAME
    Manufacturer = $computer.Manufacturer
    Model = $computer.Model
    SerialNumber = $bios.SerialNumber
    OperatingSystem = $os.Caption
    OSVersion = $os.Version
    CPU = $processor.Name
    RAMGB = [math]::Round($computer.TotalPhysicalMemory / 1GB, 2)
    CollectedAtUtc = (Get-Date).ToUniversalTime().ToString('o')
}
$record | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8
$record
