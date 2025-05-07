Import-Module ActiveDirectory

#Set variables
$blnused = $true
$loginshell = "/bin/bash"
$gidnumber = "100"
$homeroot = "/home"
$searchbase = "OU=ExpediaAccts,dc=decaf,dc=expecn,dc=com"
$ADSever = "aoexadcdecaf001.decaf.expecn.com"

#Get uidNumbers from AD and add them to a hashtable
$uidtable = @{}
$alluid = Get-ADUser -Properties:uidNumber -Filter {(uidNumber -like '*')} -server $ADSever
Foreach ($uid in $alluid)
	{
	$uidtable.Add($uid.samAccountName,$uid.uidNumber)
	}

#Get the next available UID
$maxuid = $uidtable.GetEnumerator() | Sort-Object Value -Descending | Select -First 1
$nextuid = $maxuid.Value

#Hardcode the $nextuid variable to force new uidNumbers to start at a certain value
#$nextuid = 11000

#Get all users without a uidNumber and apply one
$nouid = Get-ADUser -SearchBase $searchbase -Filter {(uidNumber -notlike '*') -and (enabled -eq $true)} -SearchScope Subtree  -server $ADSever

If ($nouid -ne $null)
	{
	Foreach($user in $nouid)
		{
		$alias=$user.samAccountName
		Do	
			{
			$nextuid = $nextuid + 1
			$blnused = $uidtable.ContainsValue($nextuid)
			}
			While ($blnused -eq $true)

		Write-Host "Applying $nextuid to $alias..."
		$homedirectory = "$homeroot/$alias"
		#Write-Host "Setting UNIX home directory for $alias to $homedirectory..."
		Set-ADUser $alias -Replace @{uidNumber="$nextuid";loginShell="$loginshell";unixHomeDirectory="$homedirectory";gidNumber="$gidnumber"}  -server $ADSever
		}
	}