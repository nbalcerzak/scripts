########################################################################################
# This script was created to copy and install the Blade Logic software in bulk.
# It parses a text file with servers, checks for a directory and creates if needed,
# then copies files and installs with output to a text file for logging.
#
# Created by - nbalcerzak june-13-2016
# Updated by - 
########################################################################################

# File location of server list.
$servername = Get-content -path "c:\servers.txt"

$destinationfolder = "c:\temp\bladelogic"

# Source files - can be changed to what ever environment is needed for where the source file is located.
$sourcefile = "\\che-opsfil01.ch.expeso.com\Software\Applications\BladeLogic\AgentInstallScript\ADS-Install\_Install\*"

# This section will install the software
foreach ($ComputerName in $servername)
    {
        # This section will copy the $sourcefile to the $destinationfolder. If the Folder does not exist it will create it.
        if (!(Test-Path -path $destinationfolder))
            {
                New-Item $destinationfolder -Type Directory
            }
     
        Copy-Item -Path $sourcefile -Destination $destinationfolder
     
        # Install Blade Logic
        # invoke-command -script {c:\temp\bat.bat} -computer server1
        psexec \\CHEXTFXCLI004 -u "expeso\nbalcerzak" -p <somepassword> c:\temp\blagentInstall_x64.cmd
        
        if ($setup.exitcode -eq 0)
            {
                $result = "The Installation of Blade Logic is Successful"
                $date = get-date -format g
            }
        else
            {
                $result = "The Installation of Blade Logic has Failed"
                $date = get-date -format g
            } 
        
        write-host $result

        #Output the install results to a local drive
        Out-File -FilePath C:\temp\BL_Install.txt -Append -InputObject ("ComputerName: $computerName Result: $result $Date")
    
    }