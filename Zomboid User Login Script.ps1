<# 
    .NAME
        Project Zomboid User Status
    .DESCRIPTION
       List users current status, whether online or offline

    .NOTES
        Written for use in the Project Zomboid community   

        Author:             James May
        Email:              Tiger770@hotmail.com
        Last Modified:      12/3/2024

        Changelog:
            a1.0             Initial Development
            a2.0             Improved script by replacing static name matching with dynamic sets, as well as added a variable for logfile path
            a3.0             Added a check for an empty logfile.
            a4.0             Modified to create an ouput HTML file showing player status or logfile issues.                                        
#>
#MODIFY BELOW WITH THE PATH TO YOUR PVP LOG, but leave the LOGFILE alone
$logpath = "\\192.168.1.148\appdata\projectzomboid\Zomboid\Logs\" # Path to dedicated server logs
$logfile = "*pvp.txt" # Do not change this variable
$logindata = @()  # Do not change this variable
$outputPath = "C:\users\tiger\OneDrive\Desktop\index.html" # Path to temp write HTML file
$webserverHTMLDirectory = "\\192.168.1.148\appdata\binhex-nginx\nginx\html\" # Path to the root folder of your website

#Cleanup Previous History - for testing purposes to ensure the data sets are current
$nothing = $null
$loginhistory = $null
$ModifiedData = $null
$lastentry=@()

#Pull the PVP log
$loginhistory = get-content "$logpath$logfile"

#If the log file isn't empty
if($loginhistory -ne $null){

    #Clean it up
    $loginhistory = $loginhistory -replace '[[]', $nothing
    $loginhistory = $loginhistory -replace '[]]', $nothing
    $LoggedIn = "has logged on"
    $LoggedOut = "has logged off"

    $ModifiedData = $loginhistory -replace "restore safety enabled=true last=true cooldown=0.0 toggle=0.0.", $LoggedIn
    $ModifiedData = $ModifiedData -replace "store safety enabled=true last=true cooldown=0.0 toggle=0.0.", $LoggedOut

    #Convert to Array
    $ModifiedData = $ModifiedData | ConvertFrom-Csv -Header "Date","Time","Type","User","has","logged","status" -Delimiter " "

    #Build Usernames list
    $usernames = $modifiedData | Select-Object -ExpandProperty User -Unique

    #Get last entry for each username
    foreach ($user in $usernames) {
        $lastentry += $ModifiedData | Where-Object -Property User -eq $user | Select-Object -last 1
    }

    #write out status
    foreach ($user in $lastentry) {
        $logindata += New-Object PSObject -Property @{
            User = $user.User
            Status = $user.status
        }
    }
}

    #Get the current date and time
    $currentDateTime = (Get-Date).ToString()

# If the data we pulled isn't empty
if ($logindata -ne $null) {
    

    
    #Create the HTML content
    $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Project Zomboid Players</title>
    <style>
        body {
            text-align: center;
            font-family: Arial, sans-serif;
            background-color: #121212; /* Dark background */
            color: #E0E0E0; /* Light text color */
        }
        table {
            width: 50%;
            border-collapse: collapse;
            margin: 25px auto;
            font-size: 18px;
            text-align: center;
            background-color: #333; /* Dark background for table */
            color: #E0E0E0; /* Light text color */
        }
        th, td {
            padding: 12px;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #444; /* Dark background for headers */
        }
        .online {
            background-color: #388E3C; /* Darker green for online status */
        }
    </style>
</head>
<body>
    <h2>Project Zomboid Players</h2>
    <table>
        <tr>
            <th>Name</th>
            <th>Status</th>
        </tr>

"@

    #Append data to the HTML content
    foreach ($item in $logindata) {
        $rowClass = if ($item.Status -eq "on") { "class='online'" } else { "" }
        $htmlContent += "<tr $rowClass><td>$($item.User)</td><td>$($item.Status)</td></tr>"
    }

    #Close the table and HTML tags
    $htmlContent += @"
    </table>
    <p>Last Refreshed $currentDateTime</p>
</body>
</html>
"@

    #Save the HTML content to a file
    $htmlContent | Out-File -FilePath $outputPath -Encoding UTF8

    #copy the index page to nginx webserver
    Copy-Item -Path $outputPath -Destination $webserverHTMLDirectory -Force

}

#If there is no log detected in the root path
else {
    
    #Create the HTML content
    $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Project Zomboid Players</title>
    <style>
        body {
            text-align: center;
            font-family: Arial, sans-serif;
            background-color: #121212; /* Dark background */
            color: #E0E0E0; /* Light text color */
        }
        .message {
            margin-top: 50px;
            font-size: 24px;
            color: red;
        }
    </style>
</head>
<body>
    <h2>Project Zomboid Players</h2>
    <div class='message'>
        PVP Logfile not found. Incorrect path or no players logged in since the last server save point.
    </div>
    <p>Last Refreshed $currentDateTime</p>
</body>
</html>
"@

    #Save the HTML content to a file
    $htmlContent | Out-File -FilePath $outputPath -Encoding UTF8

    #copy the index page to nginx webserver
    Copy-Item -Path $outputPath -Destination $webserverHTMLDirectory -Force

}