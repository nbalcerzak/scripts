$creds = get-credential
$TestList = Test-Path C:\temp\servers.txt #Tests if the input list is present
$ComputersList = Get-Content C:\temp\servers.txt #Parse the input list and populate it in ComputersList
$ComputersCount = $ComputersList.Count

New-Item c:\temp\conf_update_results.txt -type file -Force

Write-Host "Updating Telegraf conf file on " -NoNewLine; Write-Host "$ComputersCount devices." -ForegroundColor Yellow
$Confirm = Read-Host "Are you sure you want to proceed? Y/N" #Confirmation required to proceed

if ($Confirm -eq 'Y')
{
$FailureCount = 0
$SuccessCount = 0

foreach ($Computer in $ComputersList) #Loop for each item in the input list
{
Write-Host "Updating conf file on $Computer"
$A = Get-Date; Add-Content c:\temp\conf_update_results.txt "$A Updating conf file on $Computer"
$Session = New-PSSession -ComputerName $Computer -Credential $Creds
    Try {
        Copy-Item -Path "\\chlxutlscm001\source`$\Apps\Telegraf\telegraf.conf" -Destination "c:\program files\telegraf\base\" -ToSession $Session -Force
        get-Service -ComputerName $computer -Name "Telegraf" | Restart-Service
        }
    Catch {
        Add-Content c:\temp\conf_update_results.txt "$Computer $PSItem"
        }
}
}

Write-Host "Have a good day!"
Pause
