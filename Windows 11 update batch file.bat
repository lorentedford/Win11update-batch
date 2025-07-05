# Define log path
$logPath = "$env:USERPROFILE\Desktop\windowsupdatelog.txt"

# Start logging
Start-Transcript -Path $logPath -Append

# Install PSWindowsUpdate if not already present
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Write-Output "`n📦 Installing PSWindowsUpdate module..."
    Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
    Install-Module -Name PSWindowsUpdate -Force -AllowClobber -Scope CurrentUser
}
Import-Module PSWindowsUpdate

# Scan and install updates
Write-Output "`n🔄 Running full update with Microsoft Update..."
Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -AutoReboot -ErrorAction SilentlyContinue

# Trigger optional updates via UsoClient
Write-Output "`n🧠 Triggering additional update scans (UsoClient fallback)..."
& UsoClient StartScan
& UsoClient StartDownload
& UsoClient StartInstall

# Update Microsoft Store apps
Write-Output "`n🏬 Updating Microsoft Store apps..."
Get-AppxPackage -AllUsers | ForEach-Object {
    $manifest = "$($_.InstallLocation)\AppXManifest.xml"
    if (Test-Path $manifest) {
        Try {
            Add-AppxPackage -DisableDevelopmentMode -Register $manifest -ErrorAction SilentlyContinue
        } Catch {}
    }
}
Start-Process "ms-windows-store://downloadsandupdates"

# Optional: Cleanup
Write-Output "`n🧹 Running Disk Cleanup..."
Start-Process "cleanmgr.exe" -ArgumentList "/sagerun:1"

Write-Output "`n✅ Updates complete. Check the log for details: $logPath"

# End logging
Stop-Transcript
