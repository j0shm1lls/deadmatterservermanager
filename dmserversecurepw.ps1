#Maximum Memory (in GB) you want the DM Server to use - do not set lower than 11gb (20-25 is what I would recommend)
$MaxMem = '25'

#path to SteamCMD.exe install
$SteamCMD = 'c:\SteamCMD\steamcmd.exe'

#Path to DeadMatter Dedicated Server Installation
$DMDediPath = "C:\Program Files (x86)\Steam\steamapps\common\Dead Matter Dedicated Server"

#path to steam_appid.txt file to check if exists
$steamappidpath = "$DMDediPath\deadmatter\Binaries\Win64\steam_appid.txt"

#path to deadmatterServer-Win64-Shipping.exe
$dmserverexe = "$DMDediPath\deadmatter\Binaries\Win64\deadmatterServer-Win64-Shipping.exe"

#Dead Matter Dedicated Server Steam APP ID (you shouldn't have to change this)
$AppID = '1110990'

#!!!!!---------DON'T TOUCH ANYTHING BELOW THIS LINE---------!!!!!

#Steam Username
$username = Read-Host -Prompt ' Please enter your Steam User Name'

#Steam Password
$SecurePassword = Read-Host -Prompt ' Please enter your Steam Password' -AsSecureString
$BSTR = `
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
$pwd = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

#Checking if Steam Guard is active and prompting for Steam Guard key if it is
write-host "`n Performing first boot check for SteamGuard...`n" -ForeGroundColor White
Start-Process -FilePath $SteamCMD -ArgumentList ('+login',$username,$pwd,'+exit') -NoNewWindow -Wait 
cls

#checking if steam_appid.txt exists, if not, creating...
if (Test-Path -Path $steamappidpath){
write-host "`n steam_appid.txt exists, continuing..." -ForeGroundColor White
}else{
New-Item ($steamappidpath) -ItemType "File" -Value "575440"
write-host "`n Steam_AppId.txt created successfully, continuing..."
}

#main loop
while($true)
{
$i++
#Checking for DM Server Updates
$SteamCMDLog = "$env:Temp\SteamCMDLog.log"
    if (Test-Path $SteamCMDLog){del $SteamCMDLog}
	        write-host "`n Checking for Dead Matter Dedicated Server update...`n" -ForeGroundColor White
& $SteamCMD '+login' $username $pwd '+force_install_dir' "`"$DMDediPath`"" '+app_update' $AppID '+exit' -wait | Tee-Object $SteamCMDLog
$updatedm = Get-Content $SteamCMDLog -Raw	
	if ($updatedm -like "*Success! App '$AppID' fully installed.*"){
	        write-host "`n Dead Matter Dedicated Server is installed and up to date!" -ForegroundColor Green
	    del $SteamCMDLog
	    $updatedm = $null
}else{
	if ($updatedm -like "*App '$AppID' already up to date.*"){
    	    write-host "`n Dead Matter Dedicated Server is already up to date!" -ForegroundColor Green
	    del $SteamCMDLog
	    $updatedm = $null
}else{
	        write-host "`n Downloading or Updating of Dead Matter Dedicated Server failed! Please try running again.`n" -ForegroundColor black -BackgroundColor red
        del $SteamCMDLog
        $updatedm = $null
}}
Start-Sleep -s 1

#Fancy animation letting you know the DM Server is launching
$pretext = "`(o_O`)`=`╤`─`─"
$date = get-date
$text = "      Dead Matter Dedicated Server launched at $date     [¬º-°]¬"
$text2 = "      Dead Matter Dedicated Server launched at $date     [¬x-X]¬"
$Array = $text2.ToCharArray()
$idx = 0
$scroll = " $pretext$text"
write-host "`n`n`r $pretext $text  " -NoNewline -ForegroundColor White
start-sleep -s 2
write-host "`r $pretext " -NoNewline -ForegroundColor White
foreach ($_ in $Array){
write-host "▬" -NoNewline -ForegroundColor Yellow
start-sleep -milliseconds 5
write-host `b -NoNewline -ForegroundColor White
write-host $Array[$idx] -NoNewline -ForegroundColor White
$idx++
start-sleep -milliseconds 5}
write-host "▓" -NoNewline -foregroundcolor Red
start-sleep -milliseconds 100
write-host "▓" -NoNewline -foregroundcolor Red
start-sleep -milliseconds 100
write-host "▒" -NoNewline -foregroundcolor Red
start-sleep -milliseconds 100
write-host "▒" -NoNewline -foregroundcolor Red
start-sleep -milliseconds 100
write-host "░" -NoNewline -foregroundcolor Red
start-sleep -milliseconds 100
write-host "░`n`n" -foregroundcolor Red
start-sleep -s 2

#Launching DM Server
Start-Process -FilePath "$DMDediPath\deadmatterServer.exe" -ArgumentList "-USEALLAVAILABLECORES -log"
start-sleep -s 2

#Calculating and displaying DM Server Pageable Memory Use in GB
$shutdown = $null
$p = "deadmatterserver-win64-shipping"
while (Get-Process $p -EA SilentlyContinue){
Do
{
write-host -NoNewline "`r Dead Matter Dedicated Server is currently using:" $([math]::Round($(($DMRamUSE = Get-Process $P -EA SilentlyContinue | select -ExpandProperty PM)/1Gb),2))"GB of Memory...   "
$proc = Get-Process $p -EA SilentlyContinue
start-sleep -s 2
} While ((Get-Process $p -EA SilentlyContinue) -and ($proc.PM/1Gb) -lt $MaxMem)

#Killing DM Server if Pageable Memory use exceeds $MaxMem
while (Get-Process $p -EA SilentlyContinue) 
{
$wshell = New-Object -ComObject wscript.shell;
$wshell.AppActivate($dmserverexe) | out-null
Start-Sleep -Seconds 1 
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait('^C');
write-host "`n`n Dead Matter Server exceeded set Max Memory Use, restarting. `n Waiting 20 seconds for the server to shutdown gracefully..." -ForegroundColor Red
$shutdown = "m"
Start-Sleep -Seconds 20
if(Get-Process $p -EA SilentlyContinue){write-host "`n Server is still running, waiting an additional 20 seconds..." -ForegroundColor Red
start-sleep -Seconds 20
}
if(Get-Process $p -EA SilentlyContinue){write-host "`n Server did not shutdown gracefully, sending kill command..." -ForegroundColor Red
kill -processname $p -EA SilentlyContinue
start-sleep -Seconds 1
}
start-sleep -Seconds 1
}}
if($shutdown -eq "m"){write-host "`n`n Dead Matter Server successfully shutdown, restarting...`n" -ForegroundColor Green
start-sleep -s 2
Select-String -Path "$DMDediPath\deadmatter\Saved\Logs\deadmatter.log" -Pattern 'LogCore'-AllMatches | Foreach {$_.Line}
write-host "`n`n Server closed at: $(Get-Date)`n" -ForeGroundColor White
start-sleep -s 5
}else{
write-host "`n`n Dead Matter Server was shut down or crashed, restarting...`n" -ForegroundColor Red
start-sleep -s 2
Select-String -Path "$DMDediPath\deadmatter\Saved\Logs\deadmatter.log" -Pattern 'LogCore'-AllMatches | Foreach {$_.Line}
write-host "`n`n Server closed at: $(Get-Date)`n" -ForeGroundColor White
start-sleep -s 5
}
}