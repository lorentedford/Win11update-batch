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

## How to Use 🚀

1.  **Download**: Save the script file (e.g., `Windows 11 update batch file.ps1`) to a convenient location, such as your Desktop.
2.  **Unblock the File**: Before the first run, you must unblock the script.
    * Right-click the `.ps1` file and choose **Properties**.
    * At the bottom of the **General** tab, check the **Unblock** box.
    * Click **Apply**, then **OK**.
    ![Unblock file in properties](https://i.imgur.com/gSoJ5Gv.png)
3.  **Run**: Right-click on the `.ps1` file and select **Run with PowerShell**.
4.  **Approve UAC Prompt**: The script will ask for administrator rights. Click **Yes** to grant the necessary permissions.
5.  **Let it Run**: The script will now perform all its tasks. This may take a significant amount of time and may include an automatic reboot to complete updates.

---

## Troubleshooting

If the script window closes immediately after you run it, it's almost always a security setting. Please try the solutions below in order.

### Solution 1: Unblock the Script File (Most Common Fix)

If you forgot to unblock the file as described in the "How to Use" section, the script will be blocked by Windows. Follow step 2 from the "How to Use" section above. This solves the problem for most users.

### Solution 2: Set Execution Policy

If unblocking the file doesn't work, your system's Execution Policy may be too restrictive. This is a one-time setup to allow local scripts to run.

1.  **Open Terminal as Admin**: Right-click on your Start Menu and select **Terminal (Admin)**.
2.  **Run the Command**: In the admin terminal, type `Set-ExecutionPolicy RemoteSigned` and press **Enter**.
3.  **Confirm**: Type `Y` and press **Enter** to confirm the change.

### Solution 3: The Direct Launcher Method (Bypass)

If you still have issues, this final method bypasses all policy and blocking issues entirely.

1.  **Open Terminal as Admin**: Right-click on your Start Menu and select **Terminal (Admin)**.
2.  **Copy and Paste the Command**: Copy the entire command below and paste it into the admin terminal.
    > **Note**: If you rename the script file, you must update the filename in this command.

    ```powershell
    PowerShell -ExecutionPolicy Bypass -File "$env:USERPROFILE\Desktop\Windows 11 update batch file.ps1"
    ```
3.  **Press Enter**: The script will now begin running directly inside the terminal window.

---

## Log Files 📁

All actions are recorded in log files for troubleshooting and review.

* **Location**: `C:\updatelogs`
* **Current Log**: The log for the session currently running is named `Log_current_yyyy-MM-dd_HH-mm-ss.txt`.
* **Archived Logs**: Once a new session starts, the previous "current" log is renamed, compressed into a `.zip` file, and stored in the same directory for historical records.

---

**Disclaimer**: This script is provided as-is. Always ensure you have backups of important data before running any system-level scripts.
