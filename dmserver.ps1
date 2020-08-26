#Steam Username
$username = 'YourSteamUsername'

#Steam Password
$pwd = 'YourSteamPassword'

#path to SteamCMD.exe install
$SteamCMD = 'c:\SteamCMD\steamcmd.exe'

#Path to DeadMatter Dedicated Server Installation
$DMDediPath = "C:\Program Files (x86)\Steam\steamapps\common\Dead Matter Dedicated Server"

#Dead Matter Dedicated Server Steam APP ID (you shouldn't have to change this)
$AppID = '1110990'

#!!!!!---------DON'T TOUCH ANYTHING BELOW THIS LINE---------!!!!!

#Checking if Steam Guard is active and prompting for Steam Guard key if it is
write-host "`n Performing first boot check for SteamGuard...`n" -ForeGroundColor White
Start-Process -FilePath $SteamCMD -ArgumentList ('+login',$username,$pwd,'+exit') -NoNewWindow -Wait 

#main loop
while($true)
{
$i++
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
	write-host "`n `(`•̪`●`)`=`╤`─`─ Dead Matter Dedicated Server launched at: $(Get-Date) `-`n" -ForeGroundColor White
Start-Process -FilePath "$DMDediPath\deadmatterServer.exe" -ArgumentList "-USEALLAVAILABLECORES -log" -Wait
	write-host " Server closed at: $(Get-Date)`n" -ForeGroundColor White
Select-String -Path "$DMDediPath\deadmatter\Saved\Logs\deadmatter.log" -Pattern 'LogCore'-AllMatches | Foreach {$_.Line}
	write-host "`n Server shutdown or crashed, Restarting...`n" -ForegroundColor black -BackgroundColor red
Start-Sleep -s 3
}