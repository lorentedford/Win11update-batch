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
