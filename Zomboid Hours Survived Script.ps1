<# 
    .NAME
        Project Zomboid User Survived Leaderboard
    .DESCRIPTION
       List users current status, whether online or offline

    .NOTES
        Written for use in the Project Zomboid community   

        Author:             James May
        Email:              Tiger770@hotmail.com
        Last Modified:      2/12/2025

        Changelog:
            a1.0             Initial Development
            b1.0             Created Additional Pages Skills and Hours Survived. Added Navbar to All Pages.
            b1.1             Add CSS active class to highlight active navbar page on all pages.                         
#>
#MODIFY BELOW WITH THE PATH TO YOUR PVP LOG, but leave the LOGFILE alone
$logpath = "\\192.168.1.148\appdata\projectzomboid\Zomboid\Logs\" # Path to dedicated server logs
$logfile = "*PerkLog.txt" #  Do not change this variable
$outputPath = "C:\users\tiger\OneDrive\Desktop\survived_hours.html" # Path to temp write HTML file
$webserverHTMLDirectory = "\\192.168.1.148\appdata\binhex-nginx\nginx\html\" # Path to the root folder of your website

#Cleanup Previous History - to ensure the data sets are current
$nothing = $null
$Perks = $null
$ModifiedData = $null
$result = $null
$text = $null
$lastentry = $null
$combineddata = @()

#Pull the Perk log
$Perks = get-content "$logpath$logfile"

#Clean up the log
if($Perks -ne $null){

#Replace unwanted data
    $pattern = "\]\["
    $replacement = " "
    $text = $Perks -replace $pattern, $replacement
    $leadingbracket = "\["
    $trailingbracket = "\]"
    $survived = "Login Hours Survived: "
    $replacement = $nothing
    $text = $text -replace $leadingbracket, $replacement
    $text = $text -replace $trailingbracket, $replacement
    $text = $text -replace $survived, $replacement

#Convert to Array
    $ModifiedData = $text| ConvertFrom-Csv -Header "Date","Time","ID","User","Location","Survived" -Delimiter " "
    
#Remove the period in survived
    $ModifiedData = $ModifiedData | ForEach-Object { 
    $_.Survived = $_.Survived -replace "\.", "" 
    $_ 
    }

#Build Usernames list
    $usernames = $modifiedData | Select-Object -ExpandProperty User -Unique
    
#Get first entry for each username
    foreach ($user in $usernames) {
        $lastentry = $ModifiedData | Where-Object -Property User -eq $user | Select-Object -First 1
        $combineddata += $lastentry
     }
}

#Get the current date and time
$currentDateTime = (Get-Date).ToString()

#Create HTML content
$html = @"
<!DOCTYPE html>
<html">
<head>
    <title>Project Zomboid Hours Survived</title>
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
        .navbar {
            margin: 20px;
        }
        .navbar a {
            margin: 10px;
            padding: 10px;
            color: #E0E0E0;
            text-decoration: none;
            border: 1px solid #E0E0E0;
        }
        .navbar a.active {
            background-color: #388E3C; /* Highlight active link */
        }
    </style>
</head>
<body>
    <h2>Project Zomboid Hours Survived</h2>
    <div class="navbar">
        <a href="skills.html">Skills Comparison</a>
        <a href="survived_hours.html" class="active">Hours Survived Comparison</a>
        <a href="index.html">Player Status</a>
    </div>
    <table>
        <tr>
            <th>Username</th>
            <th>Survived</th>
        </tr>
"@

#Populate the table with user data
    foreach ($entry in $combineddata) {
        $html += "<tr>"
        $html += "<td>$($entry.User)</td>"
        $html += "<td>$($entry.Survived)</td>"
        $html += "</tr>"
    }

    $html += @"
    </table>
    <p>Last Refreshed $currentDateTime</p>
</body>
</html>
"@

#Save the HTML content to a file
$html | Out-File -FilePath $outputPath

#Copy the index page to nginx webserver
Copy-Item -Path $outputPath -Destination $webserverHTMLDirectory -Force