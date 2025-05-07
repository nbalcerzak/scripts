#$Server will provide line item path of servers (either IP or FQDN)
$server = Get-Content "C:\serverlist.txt"

#Output Results File
$output = "C:\serverlist-out.txt"

#$Cred will supply appropriate credentials for domain or can be used with remote host local admin
$cred = Get-Credential corp\nbalcerzak

#Get Fully Qualified Domain Name of Host Machine
$myFQDN = $env:computername.$env:userdnsdomain

#Filter Service Names
$service = "Name LIKE 'Tanium Client Installer'"

#Remote connection to servers in list to query availability and running services
Foreach ($i in $server) 
{if (Test-Connection $i -Count 1 -Quiet)
    {$i | ForEach-Object {Get-WmiObject -Class Win32_Product -Filter $service | Out-File $output -Append}}
    {$i | ForEach-Object {("$i has no connection") | Out-File $output -Append}}
}
Else {("$i has no connection") | Out-File $output -Append}
}