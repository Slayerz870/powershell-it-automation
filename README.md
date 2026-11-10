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
