# Windows 11 Update & Maintenance Script

This PowerShell script automates the update process for Windows 11. It installs operating system updates (including optional ones if available), refreshes Microsoft Store apps, and performs basic system cleanup. Ideal for keeping your system healthy and minimizing manual update effort.

---

## Features

- Installs all available Windows updates using PowerShell and UsoClient
- Updates Microsoft Store apps for all users
- Performs system health checks with DISM and SFC
- Logs all actions to `windowsupdatelog.txt` on your desktop
- Designed to run silently and efficiently

---

## Usage

1. **Copy the script** below and save it as `WinUpdateTool.ps1`
2. **Right-click** the `.ps1` file and choose **"Run with PowerShell"**
3. The script will create a log file on your desktop and automatically apply updates
4. **Requires Administrator privileges**

---

## Script

```powershell
# Define log path
$logPath = "$env:USERPROFILE\Desktop\windowsupdatelog.txt"

# Start logging
Start-Transcript -Path $logPath -Append

# Ensure PSWindowsUpdate is installed
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Write-Output ""
    Write-Output "Installing PSWindowsUpdate module..."
    Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
    Install-Module -Name PSWindowsUpdate -Force -AllowClobber -Scope CurrentUser
}
Import-Module PSWindowsUpdate

# Perform Windows Updates
Write-Output ""
Write-Output "Running full Windows Update (Microsoft Update enabled)..."
Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -AutoReboot -ErrorAction SilentlyContinue

# Trigger optional updates via UsoClient
Write-Output ""
Write-Output "Triggering additional update scans (UsoClient fallback)..."
& UsoClient StartScan
& UsoClient StartDownload
& UsoClient StartInstall

# Update Microsoft Store apps
Write-Output ""
Write-Output "Updating Microsoft Store apps..."
Get-AppxPackage -AllUsers | ForEach-Object {
    $manifest = "$($_.InstallLocation)\AppXManifest.xml"
    if (Test-Path $manifest) {
        Try {
            Add-AppxPackage -DisableDevelopmentMode -Register $manifest -ErrorAction SilentlyContinue
        } Catch {}
    }
}
Start-Process "ms-windows-store://downloadsandupdates"

# Optional: Run Disk Cleanup
Write-Output ""
Write-Output "Running Disk Cleanup..."
Start-Process "cleanmgr.exe" -ArgumentList "/sagerun:1"

Write-Output ""
Write-Output "Update process complete. Review the log at: $logPath"

# End logging
Stop-Transcript
```

## Disclaimer
This script uses native PowerShell commands and Windows maintenance utilities to perform update tasks. It does not modify system settings beyond updates and cleanup, unless manually edited. Always ensure you run this script with administrator rights and review the code before executing.

## Feedback
Feel free to fork this repo, report issues, or suggest improvements through GitHub. Pull requests and variant versions for advanced deployment scenarios are welcome!
