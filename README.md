# Windows 11 Update, Repair, and Maintenance Script

This PowerShell script provides a comprehensive, all-in-one solution for keeping your Windows 11 system up-to-date, healthy, and clean. It automates the entire process, from checking for administrator rights to updating apps and cleaning up system files.

It is designed to be safe, efficient, and user-friendly.

---

## Features ✨

* **Self-Elevating**: Automatically prompts for Administrator privileges if not already running with them.
* **Log Archiving**: Creates a new timestamped log file for each session. It also automatically zips and archives the previous log, keeping your log folder clean.
* **System File Repair**: Checks the integrity of the core Windows system image and system files using **DISM** and **SFC**, and attempts to repair any corruption it finds.
* **Complete Windows Updates**: Utilizes the `PSWindowsUpdate` module to find, download, and install all available updates for Windows, including Microsoft products.
* **Modern App Updates**: Updates all your installed Microsoft Store and other apps using the official **Windows Package Manager** (`winget`).
* **Automated Disk Cleanup**: Runs the Windows Disk Cleanup tool with your saved settings to free up disk space.

---

## Prerequisites

* **Operating System**: Windows 11 (Pro recommended).
* **PowerShell**: Version 5.1 or higher (This is standard on Windows 11).
* **Execution Policy**: The script will attempt to set the execution policy for its own process, but if you have a globally restrictive policy, you may need to adjust it.

---

## How to Use 🚀

Using this script is simple. No manual terminal commands are needed.

1.  **Download**: Save the script file (e.g., `Update-System.ps1`) to a convenient location, such as your Desktop.
2.  **Run**: Right-click on the `Update-System.ps1` file and select **Run with PowerShell**.

    ![How to run script](https://i.imgur.com/8aIM2aC.png)

3.  **Approve UAC Prompt**: The script will first check if it has administrator rights. If not, a User Account Control (UAC) window will pop up. Click **Yes** to grant the necessary permissions.

    ![UAC Prompt](https://i.imgur.com/Vli2z5B.png)

4.  **Let it Run**: A new PowerShell window will open and the script will begin its work. You will see its progress in the terminal. The process can take a significant amount of time, especially the DISM, SFC, and Windows Update steps.
5.  **Reboot (If Necessary)**: The Windows Update portion of the script may trigger an automatic reboot to finish installing updates. This is expected behavior. The script will not resume automatically after the reboot.
6.  **Done**: Once finished, the script will display a completion message and wait for you to press Enter before closing.

---

## Log Files 📁

All actions are recorded in log files for troubleshooting and review.

* **Location**: `C:\updatelogs`
* **Current Log**: The log for the session currently running is named `Log_current_yyyy-MM-dd_HH-mm-ss.txt`.
* **Archived Logs**: Once a new session starts, the previous "current" log is renamed, compressed into a `.zip` file, and stored in the same directory for historical records.

---

## Script Breakdown

The script executes its tasks in the following order:

1.  **Administrator Check**: Ensures the script has the required permissions to run.
2.  **Log Management**: Archives the old log file and starts a new one.
3.  **System Image Repair**: Runs `DISM /Online /Cleanup-Image /RestoreHealth` to repair the Windows Component Store.
4.  **System File Check**: Runs `sfc /scannow` to find and fix protected system files.
5.  **Module Installation**: Checks for and installs the `PSWindowsUpdate` module if it's not already present.
6.  **Windows Update**: Downloads and installs all available updates.
7.  **Application Update**: Updates all apps via `winget`.
8.  **Disk Cleanup**: Runs `cleanmgr.exe` to clear out temporary files and other clutter.

---

**Disclaimer**: This script is provided as-is. Always ensure you have backups of important data before running any system-level scripts.
