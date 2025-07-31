# Windows 11 Update & Maintenance Script

This PowerShell script automates the update process for Windows 11. It installs operating system updates (including optional ones if available), refreshes Microsoft Store apps, and performs basic system cleanup. Ideal for keeping your system healthy and minimizing manual update effort.

---

## Features

- Installs all available Windows updates using PowerShell and UsoClient
- Updates Microsoft Store apps for all users
- Performs system health checks with DISM and SFC
- Logs all actions to `C:\updatelogs` `WindowsUpdateLog.txt` on your desktop
- Designed to run silently and efficiently

---

## Usage

1. **Copy the script** below and save it as `WinUpdateTool.ps1`
2. **Right-click** the `.ps1` file and choose **"Run with PowerShell"**
3. The script will create a log file on your desktop and automatically apply updates
4. **Requires Administrator privileges**

---

## Script

```
#================================================================================
#               WINDOWS UPDATE, REPAIR, AND CLEANUP SCRIPT
#================================================================================
# This script will automatically request Administrator privileges if needed.
#
# It will:
# 1. Request Admin rights (UAC Prompt).
# 2. Check and repair the Windows system image (DISM & SFC).
# 3. Start a log file in C:\updatelogs\.
# 4. Install/Import the PSWindowsUpdate module.
# 5. Search for, download, and install all available Windows Updates.
# 6. Update all Microsoft Store / winget apps.
# 7. Run Disk Cleanup.
#================================================================================

#--------------------------------------------------------------------------------
# SELF-ELEVATION BLOCK
#--------------------------------------------------------------------------------
# This section checks for Admin rights and re-launches the script if needed.

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # If not running as admin, show a warning and try to re-launch.
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Write-Warning "Administrator privileges are required! Popping UAC prompt..."
    Start-Process powershell.exe -Verb RunAs -ArgumentList $arguments
    exit
}
# If we get here, we are running as an Administrator.
Write-Host "Success! Running with Administrator privileges." -ForegroundColor Green


#--------------------------------------------------------------------------------
# SCRIPT SETUP AND LOGGING
#--------------------------------------------------------------------------------

# Define log path and ensure the directory exists
$logDirectory = "C:\updatelogs"
if (-not (Test-Path -Path $logDirectory)) {
    Write-Host "Creating log directory at $logDirectory..."
    New-Item -Path $logDirectory -ItemType Directory -Force | Out-Null
}
$logPath = Join-Path -Path $logDirectory -ChildPath "WindowsUpdateLog.txt"

# Start logging
Start-Transcript -Path $logPath -Append


#--------------------------------------------------------------------------------
# SYSTEM FILE INTEGRITY CHECK & REPAIR (DISM & SFC)
#--------------------------------------------------------------------------------

Write-Host ""
Write-Host "--- Starting System File Integrity Check ---" -ForegroundColor Yellow
Write-Host "Step 1: Running DISM to check component store health. This may take a while." -ForegroundColor Cyan
DISM.exe /Online /Cleanup-Image /ScanHealth

Write-Host "Step 2: Running DISM to repair component store. This will take several minutes." -ForegroundColor Cyan
DISM.exe /Online /Cleanup-Image /RestoreHealth

Write-Host "Step 3: Running System File Checker (SFC). This may take a while." -ForegroundColor Cyan
sfc.exe /scannow
Write-Host "--- System File Integrity Check Complete ---" -ForegroundColor Green


#--------------------------------------------------------------------------------
# POWERSHELL MODULE INSTALLATION
#--------------------------------------------------------------------------------

# Ensure PSWindowsUpdate module is available
Write-Host ""
Write-Host "Checking for PSWindowsUpdate module..."
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Write-Host "Installing PSWindowsUpdate module. This may take a moment..."
    # Set execution policy to allow script installation
    Set-ExecutionPolicy RemoteSigned -Scope Process -Force
    # Install NuGet package provider
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    # Install the PowerShell module
    Install-Module -Name PSWindowsUpdate -Force -AllowClobber
}
Import-Module PSWindowsUpdate
Write-Host "PSWindowsUpdate module is ready." -ForegroundColor Green


#--------------------------------------------------------------------------------
# WINDOWS UPDATES
#--------------------------------------------------------------------------------

Write-Host ""
Write-Host "Searching for all available Windows updates..." -ForegroundColor Cyan
Get-WUList -MicrosoftUpdate

Write-Host ""
Write-Host "Starting installation of all approved updates. The system may reboot." -ForegroundColor Yellow
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -AutoReboot


#--------------------------------------------------------------------------------
# MICROSOFT STORE & WINGET APP UPDATES
#--------------------------------------------------------------------------------

Write-Host ""
Write-Host "Updating Microsoft Store and other apps via winget..." -ForegroundColor Cyan
winget upgrade --all --silent --accept-source-agreements --accept-package-agreements


#--------------------------------------------------------------------------------
# DISK CLEANUP
#--------------------------------------------------------------------------------

Write-Host ""
Write-Host "Running Disk Cleanup..." -ForegroundColor Cyan
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
if (!(Get-ItemProperty -Path $regPath -Name "StateFlags0001" -ErrorAction SilentlyContinue)) {
    Write-Warning "No Disk Cleanup profile found. Please create one now."
    Start-Process "cleanmgr.exe" -ArgumentList "/sageset:1" -Wait
} else {
    Start-Process "cleanmgr.exe" -ArgumentList "/sagerun:1"
}


#--------------------------------------------------------------------------------
# COMPLETION
#--------------------------------------------------------------------------------

Write-Host ""
Write-Host "Script process complete. Press Enter to exit." -ForegroundColor Green
Write-Host "A detailed log has been saved to: $logPath"
Read-Host

# End logging
Stop-Transcript

```

## Disclaimer
This script uses native PowerShell commands and Windows maintenance utilities to perform update tasks. It does not modify system settings beyond updates and cleanup, unless manually edited. Always ensure you run this script with administrator rights and review the code before executing.

## Feedback
Feel free to fork this repo, report issues, or suggest improvements through GitHub. Pull requests and variant versions for advanced deployment scenarios are welcome!
