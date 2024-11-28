<# 
    .NAME
        Project Zomboid User Status
    .DESCRIPTION
       List users current status, whether online or offline

    .NOTES
        Written for use in the Project Zomboid community   

        Author:             James May
        Email:              Tiger770@hotmail.com
        Last Modified:      11/27/2024

        Changelog:
            a1.0             Initial Development
            a2.0             Improved script by replacing static name matching with dynamic sets, as well as added a variable for logfile path
            a3.0             Added a check for an empty logfile.                                        
#>
#MODIFY BELOW WITH THE PATH TO YOUR PVP LOG, but leave the LOGFILE alone
$logpath = "\\192.168.1.148\appdata\projectzomboid\Zomboid\Logs\"
$logfile = "*pvp.txt"

#Cleanup Previous History - for testing purposes to ensure the data sets are current
$nothing = $null
$loginhistory = $null
$ModifiedData = $null
$lastentry=@()

#Pull the PVP log
$loginhistory = get-content "$logpath$logfile"

if($loginhistory -ne $null){

    #Clean it up
    $loginhistory = $loginhistory -replace '[[]', $nothing
    $loginhistory = $loginhistory -replace '[]]', $nothing
    $LoggedIn = "has logged on"
    $LoggedOut = "has logged off"

    $ModifiedData = $loginhistory -replace "restore safety enabled=true last=true cooldown=0.0 toggle=0.0.", $LoggedIn
    $ModifiedData = $ModifiedData -replace "store safety enabled=true last=true cooldown=0.0 toggle=0.0.", $LoggedOut

    #Convert to Array
    $ModifiedData = $ModifiedData| ConvertFrom-Csv -Header "Date","Time","Type","User","has","logged","status" -Delimiter " "

    #Build Usernames list
    $usernames = $modifiedData | Select-Object -ExpandProperty User -Unique

    #Get last entry for each username
    foreach ($user in $usernames){
     $lastentry += $ModifiedData | Where-Object -Property User -eq $user | Select-Object -last 1
     }

    #write out status
    foreach ($user in $lastentry){
    write-host $User.User "is currently" $user.Status -ForegroundColor $(if ($user.status -eq "on"){"green"} else {"red"})
    }

}

Else{
    write-host "Logfile not detected.  No Login Data to show." -ForegroundColor Red
}