# Dead Matter Server Manager
This is a Powershell script that installs, updates, launches and manages a Dead Matter Dedicated Server.

If Pageable Memory use exceeds 25GB (configurable by the end user), a kill signal is sent to the server and it is restarted.

# Prerequisites 
* You must have a Dead Matter key tied to your Steam account
* You must have SteamCMD installed - download from here https://developer.valvesoftware.com/wiki/SteamCMD#Windows
* You must enable Remote Signed PowerShell scripts
  * Open Windows Powershell with "Run as Administrator" Option
  * Set-ExecutionPolicy RemoteSigned
  * Press Y to enable

# Edits that need to be made to the script
You will have to edit the script to include:
* your Steam User Name
* you Steam Password
* Path to SteamCMD.exe (this assumes c:\SteamCMD\steamcmd.exe)
* Path to the Dead Matter Dedicated Server Installation (this it assumes the default Steam install directory)

# Launching the Server Manager
Create a new shortcut to PowerShell with the -file arg followed by the path to the script
`C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -file "C:\dmserver.ps1"`

Name the shortcut something obvious (Auto-Restart Dead Matter Server)


Run the shortcut and PowerShell should open and begin installing the Dead Matter Dedicated Server, or checking for updates it if already installed.  Once complete it will automatically launch the Dead Matter Dedicated Server.


If the server is shutdown or crashes, the script will automatically check for updates  and restart the server.
