# Requires Admin
Start-Transcript -Path "$env:USERPROFILE\Desktop\WinUpdateLog.txt" -Append

Write-Host "`n🔄 Installing PSWindowsUpdate module if needed..."
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
    Install-Module -Name PSWindowsUpdate -Force -AllowClobber -Scope CurrentUser
}
Import-Module PSWindowsUpdate

Write-Host "`n🛰️ Starting full Windows Update scan (including optionals if allowed)..."
Get-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -AutoReboot -ErrorAction SilentlyContinue

Write-Host "`n🧰 Triggering optional update scan (UsoClient fallback)..."
Start-Process -FilePath "powershell.exe" -ArgumentList "UsoClient StartScan"
Start-Process -FilePath "powershell.exe" -ArgumentList "UsoClient StartDownload"
Start-Process -FilePath "powershell.exe" -ArgumentList "UsoClient StartInstall"

Write-Host "`n🛍️ Updating Microsoft Store apps silently..."
Get-AppxPackage -AllUsers | ForEach-Object {
    $manifest = "$($_.InstallLocation)\AppXManifest.xml"
    if (Test-Path $manifest) {
        Try {
            Add-AppxPackage -DisableDevelopmentMode -Register $manifest -ErrorAction SilentlyContinue
        } Catch {}
    }
}
Start-Process "ms-windows-store://downloadsandupdates"

Write-Host "`n🧹 Optional: Cleaning up temporary update files..."
Start-Process "cleanmgr.exe" -ArgumentList "/sagerun:1"

Write-Host "`n✅ All update processes finished. Please check the desktop log for details."
Stop-Transcript