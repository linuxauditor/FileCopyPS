#location of the directory where this tool is. (LOCAL)
$wd = "C:\"

#file name of the list of Computers/Servers (LOCAL)
$list = "$wd\computers.csv"

#file(s) to be copied working directory (LOCAL)
$location = "$wd\"

#name(s) of file(s)
#Also, change to * if you need everthing copied
$file1 = "exception.sites"
$file2 = "deployment.properties"

#future containing directory of the file(s) (REMOTE)
$rwd = "C$\Windows\Sun\Java\Deployment"

#Definition of log file
$log = Get-Date -Format "dd-MM-yy-"
$username = $env:USERNAME

#SCRIPT
$computers = Get-Content $list

foreach ($computer in $computers){
    $connection= (Test-Connection -computername $computer -count 1 -quiet)
        if ($connection -eq $True){
            #Script queries all user profile on computer ecluding all accounts that start with "adm" and are names "public"
            $Users= Get-ChildItem -path \\$computer\c$\users -exclude adm*,Public
                foreach ($user in $users){                    
                    #Copies correct java files to correct folder in all users that are queries above
                    robocopy $location\ \\$computer\c$\Users\$user\AppData\LocalLow\Sun\Java\Deployment\security $file1  /mt:128 /w:1 /r:1 /log+:"$wd\logs\$log$username.log"
                    robocopy $location\ \\$computer\c$\Users\$user\AppData\LocalLow\Sun\Java\Deployment $file2  /mt:128 /w:1 /r:1 /log+:"$wd\logs\$log$username.log"
                    }                    
            #script deletes and copies the correct files into the correct folders
            Get-ChildItem -path \\$computer\$rwd\ -include * -File -Recurse | foreach { $_.Delete()}
            robocopy $location\  \\$computer\$rwd $file1,$file2 /mt:128 /w:1 /r:1 /log+:$wd\$log$username.log
            }
       Else{
       add-content -path C:\Users\%USER%\Desktop\powershell\filecopy\Logs\offline.txt "$computer"}
}
