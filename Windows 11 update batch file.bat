#================================================================================
#               WINDOWS UPDATE, REPAIR, AND CLEANUP SCRIPT
#================================================================================
# This script must be run as an Administrator.
#
# It will:
# 1. Start a log file on your Desktop.
# 2. Check for and install the PSWindowsUpdate module if needed.
# 3. Search for, download, and install all available Windows Updates.
# 4. Update all Microsoft Store / winget apps.
# 5. Run Disk Cleanup (requires one-time setup).
#================================================================================

#--------------------------------------------------------------------------------
# SCRIPT SETUP AND ADMIN CHECK
#--------------------------------------------------------------------------------

# Define log path
$logPath = "$env:USERPROFILE\Desktop\WindowsUpdateLog.txt"

# Start logging
Start-Transcript -Path $logPath -Append

# Check for Administrator privileges
Write-Host "Checking for administrator privileges..."
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Administrator privileges are required!"
    Write-Warning "Please re-run this script from an elevated PowerShell terminal."
    # Pause the script to allow the user to read the message.
    Read-Host "Press Enter to exit..."
    # Stop logging and exit
    Stop-Transcript
    exit
}
Write-Host "Success! Running as Administrator." -ForegroundColor Green


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
# The 'Get-WUList' command is used here to show what is available before installing.
# It is an alias for 'Get-WindowsUpdate -ListOnly'.
Get-WUList -MicrosoftUpdate

Write-Host ""
Write-Host "Starting installation of all approved updates. The system may reboot." -ForegroundColor Yellow
# Installs all available updates, accepts all prompts, and auto reboots if needed.
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -AutoReboot

# Note: The script may stop here if a reboot occurs. That is expected behavior.


#--------------------------------------------------------------------------------
# MICROSOFT STORE & WINGET APP UPDATES
#--------------------------------------------------------------------------------

Write-Host ""
Write-Host "Updating Microsoft Store and other apps via winget..." -ForegroundColor Cyan
# Since you're on Windows 11, winget is the standard tool for this.
# This command finds and installs all available updates for installed packages.
winget upgrade --all --silent --accept-source-agreements --accept-package-agreements


#--------------------------------------------------------------------------------
# DISK CLEANUP
#--------------------------------------------------------------------------------

Write-Host ""
Write-Host "Running Disk Cleanup..." -ForegroundColor Cyan
Write-Host "Note: If this is your first time, you must configure Disk Cleanup options first."
Write-Host "The tool will be launched for you. Check the boxes you want to clean."

# The /SAGERUN command uses a saved configuration. If it doesn't exist, you must create it with /SAGESET.
# We will check if the config exists. If not, we prompt the user to create it.
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
if (!(Get-ItemProperty -Path $regPath -Name "StateFlags0001" -ErrorAction SilentlyContinue)) {
    Write-Warning "No Disk Cleanup profile found. Please create one now."
    Write-Host "Run the following command in a new Admin Terminal: cleanmgr.exe /sageset:1"
    Start-Process "cleanmgr.exe" -ArgumentList "/sageset:1" -Wait
} else {
    Start-Process "cleanmgr.exe" -ArgumentList "/sagerun:1"
}


#--------------------------------------------------------------------------------
# COMPLETION
#--------------------------------------------------------------------------------

Write-Host ""
Write-Host "Script process complete." -ForegroundColor Green
Write-Host "A detailed log has been saved to: $logPath"

# End logging
Stop-Transcript
