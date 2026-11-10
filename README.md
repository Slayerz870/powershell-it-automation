# PowerShell IT Automation Toolkit

Practical, **read-only** Windows administration scripts for Senior Desktop Support and Systems Administration workflows. Designed for local Windows hosts and documented for safe lab evaluation.

## Included tools

| Script | Purpose | Output |
| --- | --- | --- |
| `Get-WorkstationHealth.ps1` | Collect OS version, uptime, memory, fixed disk capacity, and common pending-reboot signals | PowerShell object / optional JSON |
| `Export-WorkstationInventory.ps1` | Collect computer make/model, BIOS serial, OS, CPU, and RAM | CSV + PowerShell object |

## Requirements

- Windows PowerShell 5.1 or PowerShell 7+ **on Windows**
- Access to local CIM/WMI classes; some environments may restrict inventory fields
- Pester 5+ for syntax tests

## Usage

From a PowerShell session in the repository root:

```powershell
.\scripts\Get-WorkstationHealth.ps1 | Format-List
.\scripts\Get-WorkstationHealth.ps1 | ConvertTo-Json -Depth 5 | Out-File .\health.json
.\scripts\Export-WorkstationInventory.ps1 -Path .\inventory.csv
```

Run static tests:

```powershell
Install-Module Pester -MinimumVersion 5.0 -Scope CurrentUser
Invoke-Pester -Path .\tests -CI
```

## Safety and limitations

- Scripts make **no system changes**, but CSV/JSON output may contain sensitive machine identifiers. Do not commit real inventory reports to a public repository.
- Reboot checks cover common registry indicators, **not every** possible reboot condition.
- Scripts query the **local** computer only; no remote authentication or fleet-wide collection is implemented.
- Automated tests currently verify **syntax only**. Run functional validation on a Windows test machine before relying on output.
- Some hardware/OS properties may be unavailable or restricted by endpoint policies.

## Roadmap

- Add mocked CIM unit tests and fixture-based expected outputs
- Add threshold-based health status and structured error handling
- Add opt-in event log summary with privacy controls
- Add safe AD reporting examples using synthetic lab accounts

## Portfolio intent

This repository demonstrates readable PowerShell, CIM inventory, structured output, documentation, conservative defaults, and CI scaffolding. It does not claim production deployment or measured business impact.

## Real-World Testing & Validation

### Windows 11 Workstation Health Monitoring

The `Get-WorkstationHealth.ps1` script was tested on a Windows 11 Pro workstation using Windows PowerShell 5.1.

**Test environment**
- Operating System: Windows 11 Pro
- PowerShell: Windows PowerShell 5.1
- Installed Memory: 31.92 GB
- System Drive: Approximately 930 GB
- Validation: GitHub Actions with Pester 5

### Example Execution

```powershell
.\Get-WorkstationHealth.ps1 | ConvertTo-Json -Depth 5
```

### Sample Output

The following is a sanitized example based on a successful workstation test.

```json
{
  "ComputerName": "WINDOWS-TEST-PC",
  "OS": "Microsoft Windows 11 Pro",
  "OSVersion": "10.0.26200",
  "UptimeDays": 0.09,
  "TotalRAMGB": 31.92,
  "FixedDisks": [
    {
      "Drive": "C:",
      "SizeGB": 930.4,
      "FreeGB": 798.71,
      "FreePercent": 85.8,
      "Status": "Available"
    },
    {
      "Drive": "D:",
      "SizeGB": null,
      "FreeGB": null,
      "FreePercent": null,
      "Status": "Capacity unavailable"
    }
  ],
  "PendingReboot": true,
  "RebootIndicators": [
    "PendingFileRenameOperations"
  ]
}
```

### Troubleshooting & Engineering Improvements

**Issue 1: Incorrect System Uptime**

Initial testing revealed that the CIM `LastBootUpTime` timestamp was inconsistent with the workstation's current system clock, resulting in a negative uptime calculation.

**Resolution:** Replaced the timestamp-based uptime calculation with the Windows `\System\System Up Time` performance counter and added error handling.

**Issue 2: Zero-Capacity Disk Reporting**

A logical disk was detected without valid capacity information.

**Resolution:** Added conditional disk-capacity validation and an explicit `Capacity unavailable` status.

**Issue 3: Automated Test Failure**

The initial Pester test failed because of how the test script located and accessed the PowerShell files.

**Resolution:** Refactored the Pester test setup using `BeforeAll` and a script-scoped path variable.

### Validation Results

- PowerShell syntax validation: Passed
- GitHub Actions CI workflow: Passed
- Windows 11 functional execution: Passed
- Uptime calculation: Verified
- Disk capacity handling: Verified
- Structured JSON output: Verified

**Engineering approach:** Identify, reproduce, diagnose, correct, and validate technical issues using real-world execution results and automated testing.

