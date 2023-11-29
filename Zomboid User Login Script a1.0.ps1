<# 
    .NAME
        Project Zomboid User Status
    .DESCRIPTION
       List users current status, whether online or offline

    .NOTES
        Written for use in the Project Zomboid community   

        Author:             James May
        Email:              Tiger770@hotmail.com
        Last Modified:      11/28/2023

        Changelog:
            a1.0             Initial Development
                                                    
#>

#Cleanup Previous History - for testing purposes to ensure the data sets are current
$nothing = $null
$Galvatrondeva = $null
$UrLocalGuru = $null
$UrLocalGuwu = $null
$makelvorhang = $null
$AcidConspiracy = $null
$HackerPhreaker = $null
$GalvCraft = $null
$GalvHudsonHawk = $null
$loginhistory = $null
$ModifiedData = $null

#Pull the PVP log
$loginhistory = get-content \\192.168.1.148\appdata\projectzomboid\Zomboid\Logs\*pvp.txt

#Clean it up
$loginhistory = $loginhistory -replace '[[]', $nothing

$loginhistory = $loginhistory -replace '[]]', $nothing

$LoggedIn = "has logged on"

$LoggedOut = "has logged off"

$ModifiedData = $loginhistory -replace "restore safety enabled=true last=true cooldown=0.0 toggle=0.0.", $LoggedIn

$ModifiedData = $ModifiedData -replace "store safety enabled=true last=true cooldown=0.0 toggle=0.0.", $LoggedOut

#write it out to flat text
$ModifiedData | Out-File -FilePath \\192.168.1.148\appdata\projectzomboid\Zomboid\Logs\LoginData.txt

#import it back as an array
$ModifiedData = import-csv \\192.168.1.148\appdata\projectzomboid\Zomboid\Logs\LoginData.txt -Header "Date","Time","Type","User","has","logged","status" -Delimiter " "

#Look for users and build arrays - these variables need to be dynamically created rather than statically defined
foreach ($line in $modifiedData){
    if ($line.user -match "Galvatrondeva"){
        $Galvatrondeva +=, $line
        }

    if ($line.user -match "HackerPhreaker"){
        $HackerPhreaker +=, $line
        }

    if ($line.user -match "AcidConspiracy"){
        $AcidConspiracy +=, $line
        }
  
    if ($line.user -match "UrLocalGuru"){
        $UrLocalGuru +=, $line
        }

    if ($line.user -match "Galv-Craft"){
        $GalvCraft +=, $line
        }

    if ($line.user -match "Galv-HudsonHawk"){
        $GalvHudsonHawk +=, $line
        }
    
    if ($line.user -match "makelvorhang"){
        $makelvorhang +=, $line
        }
    
    if ($line.user -match "urlocalguwu"){
        $urlocalguwu +=, $line
        }
}

#Display results for non-empty arrays
if ($AcidConspiracy -ne $null){
    if ($AcidConspiracy[-1].status -eq "off"){
        Write-Host "AcidConspiracy is offline" -ForegroundColor Red
    }

if ($AcidConspiracy[-1].status -eq "on"){
    Write-Host "AcidConspiracy is online" -ForegroundColor Green
    }
}

if ($Galvatrondeva -ne $null){
if ($Galvatrondeva[-1].status -eq "off"){
    Write-Host "GalvatronDeva is offline" -ForegroundColor Red
    }

if ($Galvatrondeva[-1].status -eq "on"){
    Write-Host "GalvatronDeva is online" -ForegroundColor Green
    }
}

if ($GalvCraft -ne $null){
if ($GalvCraft[-1].status -eq "off"){
    Write-Host "GalvCraft is offline" -ForegroundColor Red
    }

if ($GalvCraft[-1].status -eq "on"){
    Write-Host "GalvCraft is online" -ForegroundColor Green
    }
}

if ($GalvHudsonHawk -ne $null){
if ($GalvHudsonHawk[-1].status -eq "off"){
    Write-Host "GalvHudsonHawk is offline" -ForegroundColor Red
    }

if ($GalvHudsonHawk[-1].status -eq "on"){
    Write-Host "GalvHudsonHawk is online" -ForegroundColor Green
    }
}

if ($HackerPhreaker -ne $null){  
if ($HackerPhreaker[-1].status -eq "off"){
    Write-Host "HackerPhreaker is offline" -ForegroundColor Red
    }

if ($HackerPhreaker[-1].status -eq "on"){
    Write-Host "HackerPhreaker is online" -ForegroundColor Green
    }
}

if ($makelvorhang -ne $null){
if ($makelvorhang[-1].status -eq "off"){
    Write-Host "makelvorhang is offline" -ForegroundColor Red
    }

if ($makelvorhang[-1].status -eq "on"){
    Write-Host "makelvorhang is online" -ForegroundColor Green
    }
}

if ($UrLocalGuru -ne $null){ 
if ($UrLocalGuru[-1].status -eq "off"){
    Write-Host "UrLocalGuru is offline" -ForegroundColor Red
    }

if ($UrLocalGuru[-1].status -eq "on"){
    Write-Host "UrLocalGuru is online" -ForegroundColor Green
    }
}

if ($UrLocalGuwu -ne $null){
if ($UrLocalGuwu[-1].status -eq "off"){
    Write-Host "UrLocalGuwu is offline" -ForegroundColor Red
    }

if ($UrLocalGuwu[-1].status -eq "on"){
    Write-Host "UrLocalGuwu is online" -ForegroundColor Green
    }
}