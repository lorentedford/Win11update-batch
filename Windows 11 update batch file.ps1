#================================================================================
#               WINDOWS UPDATE, REPAIR, AND CLEANUP SCRIPT
#================================================================================
# This script will automatically request Administrator privileges if needed.
#
# It provides a menu to:
# 1. Run the full update/repair/cleanup process. (Exits after completion)
# 2. Clean up old logs. (Returns to menu after completion)
#================================================================================

#--------------------------------------------------------------------------------
# SELF-ELEVATION BLOCK
#--------------------------------------------------------------------------------
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Write-Warning "Administrator privileges are required! Popping UAC prompt..."
    Start-Process powershell.exe -Verb RunAs -ArgumentList $arguments
    exit
}
Write-Host "Success! Running with Administrator privileges." -ForegroundColor Green

#--------------------------------------------------------------------------------
# MAIN SCRIPT LOOP
#--------------------------------------------------------------------------------
:MenuLoop while ($true) { # Assign the label "MenuLoop" to the while loop
    # --- SCRIPT MENU ---
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Yellow
    Write-Host "                SCRIPT MENU"
    Write-Host "===============================================" -ForegroundColor Yellow
    Write-Host "1) Run Full Update & Repair Process (Then Exits)"
    Write-Host "2) Clean Up Old Log Archives (Returns to Menu)"
    Write-Host "Q) Quit"
    Write-Host ""
    $choice = Read-Host "Enter your choice (1, 2, or Q)"

    switch ($choice) {
        '1' {
            #================================================================================
            # OPTION 1: RUN FULL UPDATE & REPAIR
            #================================================================================
            $logDirectory = "C:\updatelogs"
            if (-not (Test-Path -Path $logDirectory)) {
                Write-Host "Creating log directory at $logDirectory..."
                New-Item -Path $logDirectory -ItemType Directory -Force | Out-Null
            }
            Write-Host "Checking for old logs to archive..."
            $oldCurrentLog = Get-ChildItem -Path $logDirectory -Filter "*current*.txt" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            if ($oldCurrentLog) {
                Write-Host "Found previous log to archive: $($oldCurrentLog.Name)"
                $renamedLogName = $oldCurrentLog.Name -replace "_current", ""
                $renamedLogPath = Join-Path -Path $logDirectory -ChildPath $renamedLogName
                Rename-Item -Path $oldCurrentLog.FullName -NewName $renamedLogName
                $zipPath = $renamedLogPath -replace '\.txt$', '.zip'
                Compress-Archive -Path $renamedLogPath -DestinationPath $zipPath -Force
                Write-Host "Archived to: $zipPath" -ForegroundColor Green
                Remove-Item -Path $renamedLogPath
            } else { Write-Host "No previous logs found to archive." }
            
            $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
            $logName = "Log_current_$timestamp.txt"
            $logPath = Join-Path -Path $logDirectory -ChildPath $logName
            Write-Host "Starting new log at: $logPath"
            Start-Transcript -Path $logPath -Append

            Write-Host ""
            Write-Host "--- Starting System File Integrity Check ---" -ForegroundColor Yellow
            DISM.exe /Online /Cleanup-Image /RestoreHealth
            sfc.exe /scannow
            Write-Host "--- System File Integrity Check Complete ---" -ForegroundColor Green

            Write-Host ""
            Write-Host "Checking for PSWindowsUpdate module..."
            if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
                Write-Host "Installing PSWindowsUpdate module..."
                Set-ExecutionPolicy RemoteSigned -Scope Process -Force
                Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
                Install-Module -Name PSWindowsUpdate -Force -AllowClobber
            }
            Import-Module PSWindowsUpdate
            Write-Host "PSWindowsUpdate module is ready." -ForegroundColor Green

            Write-Host ""
            Write-Host "Searching for all available Windows updates..." -ForegroundColor Cyan
            Get-WUList -MicrosoftUpdate
            Write-Host ""
            Write-Host "Starting installation of all approved updates. The system may reboot." -ForegroundColor Yellow
            Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -Install -AutoReboot

            Write-Host ""
            Write-Host "Updating Microsoft Store and other apps via winget..." -ForegroundColor Cyan
            winget upgrade --all --silent --accept-source-agreements --accept-package-agreements

            Write-Host ""
            Write-Host "Running Disk Cleanup..." -ForegroundColor Cyan
            $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
            if (!(Get-ItemProperty -Path $regPath -Name "StateFlags0001" -ErrorAction SilentlyContinue)) {
                Write-Warning "No Disk Cleanup profile found. Please create one now."
                Start-Process "cleanmgr.exe" -ArgumentList "/sageset:1" -Wait
            } else { Start-Process "cleanmgr.exe" -ArgumentList "/sagerun:1" }

            Write-Host ""
            Write-Host "Script process complete." -ForegroundColor Green
            Write-Host "A detailed log has been saved to: $logPath"
            Stop-Transcript
            break MenuLoop # Explicitly break the labeled loop
        }
        '2' {
            #================================================================================
            # OPTION 2: CLEAN UP OLD LOGS
            #================================================================================
            Write-Host ""
            Write-Host "--- Cleaning up old log archives ---" -ForegroundColor Yellow
            $logDirectory = "C:\updatelogs"
            $cleanupThreshold = (Get-Date).AddDays(-90)
            
            if (Test-Path $logDirectory) {
                $oldLogs = Get-ChildItem -Path $logDirectory -Filter "*.zip" | Where-Object { $_.CreationTime -lt $cleanupThreshold }
                if ($oldLogs) {
                    Write-Host "Found $($oldLogs.Count) log archives older than 90 days to delete."
                    foreach ($log in $oldLogs) {
                        Write-Host "Deleting: $($log.Name) (Created: $($log.CreationTime))"
                        Remove-Item -Path $log.FullName -Force -ErrorAction SilentlyContinue
                    }
                    Write-Host "Cleanup complete." -ForegroundColor Green
                } else {
                    Write-Host "No log archives older than 90 days were found." -ForegroundColor Green
                }
            } else {
                Write-Warning "Log directory C:\updatelogs not found. No logs to clean."
            }
            Write-Host ""
            Read-Host "Operation finished. Press Enter to return to the menu..."
            continue # Go to the next iteration of the loop to re-display the menu
        }
        'Q' {
            Write-Host "Exiting script as requested."
            break MenuLoop # Explicitly break the labeled loop
        }
        'q' {
            Write-Host "Exiting script as requested."
            break MenuLoop # Explicitly break the labeled loop
        }
        default {
            Write-Warning "Invalid option selected. The script will now exit."
            break MenuLoop # Explicitly break the labeled loop
        }
    }
}

#--------------------------------------------------------------------------------
# SCRIPT EXIT
#--------------------------------------------------------------------------------
Write-Host ""
Read-Host "Operation finished. Press Enter to exit the window."
