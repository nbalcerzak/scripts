[cmdletbinding()]
Param(
    [parameter(mandatory = $true)]
    [string]$fileName,
    [parameter(mandatory = $true)]
    [System.Management.Automation.PSCredential]$Credential
)
$path = "$((Get-Location).Path)\$fileName"
$Servers = Import-Csv -Path $path;
if(Test-Path $path)
{
    
    Foreach($server in $servers)
    {
        $CMD = "netdom renamecomputer $($server.Current) /newName:$($server.New) /userd:$($Credential.UserName) /passwordd:$($Credential.GetNetworkCredential().Password) /usero:$($Credential.UserName) /passwordo:$($Credential.GetNetworkCredential().Password) /force /reboot:3 /verbose"
		Write-Host $CMD;
        Invoke-Expression -Command $CMD
    }
}
else
{
    Write-Host "Path not Found";
    Exit;
}
