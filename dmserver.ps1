#Steam Username
$username = 'SteamUserName'

#Steam Password
$pwd = 'SteamPassword'

#Maximum Memory (in GB) you want the DM Server to use - do not set lower than 11gb (20-25 is what I would recommend)
$MaxMem = '25'

#path to SteamCMD.exe install
$SteamCMD = 'c:\SteamCMD\steamcmd.exe'

#Path to DeadMatter Dedicated Server Installation
$DMDediPath = "C:\Program Files (x86)\Steam\steamapps\common\Dead Matter Dedicated Server"

#path to steam_appid.txt file to check if exists
$steamappidpath = "$DMDediPath\deadmatter\Binaries\Win64\steam_appid.txt"

#Dead Matter Dedicated Server Steam APP ID (you shouldn't have to change this)
$AppID = '1110990'

#!!!!!---------DON'T TOUCH ANYTHING BELOW THIS LINE---------!!!!!

#Checking if Steam Guard is active and prompting for Steam Guard key if it is
write-host "`n Performing first boot check for SteamGuard...`n" -ForeGroundColor White
Start-Process -FilePath $SteamCMD -ArgumentList ('+login',$username,$pwd,'+exit') -NoNewWindow -Wait 
cls

#checking if steam_appid.txt exists, if not, creating...
if (Test-Path -Path $steamappidpath){
write-host "steam_appid.txt exists, continuing..." -ForeGroundColor White
}else{
New-Item ($steamappidpath) -ItemType "File" -Value "575440"
write-host "Steam_AppId.txt created successfully, continuing..."
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
Start-Sleep -s 3
#Fancy animation
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
$p = "deadmatterserver-win64-shipping"
while (Get-Process $P -ErrorAction SilentlyContinue){
Do
{
#Calculating and displaying DM Server Pageable Memory Use in GB
write-host -NoNewline "`r Dead Matter Dedicated Server is currently using:" $([math]::Round($(($DMRamUSE = Get-Process $P -ErrorAction SilentlyContinue | select -ExpandProperty PM)/1Gb),2))"GB of Memory...  "
$proc = Get-Process $p -ErrorAction SilentlyContinue
start-sleep -s 2
} While ((Get-Process $P -ErrorAction SilentlyContinue) -and ($proc.PM/1Gb) -lt $MaxMem)
#Killing DM Server if Pageable Memory use exceeds $MaxMem
kill -processname $p -ErrorAction SilentlyContinue}
write-host "`n`n Dead Matter Server exceeded set Max Memory Use or the server was shut down, restarting...`n" -ForegroundColor Red
start-sleep -s 2
Select-String -Path "$DMDediPath\deadmatter\Saved\Logs\deadmatter.log" -Pattern 'LogCore'-AllMatches | Foreach {$_.Line}
write-host "`n`n Server closed at: $(Get-Date)`n" -ForeGroundColor White
start-sleep -s 5
}
