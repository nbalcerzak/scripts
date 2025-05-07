#Populate the gidNumber on a group passed as an argument
#Usage: \SetGIDNUmber.ps1 groupname

#Display usage information 
If ($args[0] -eq $null)
	{
	Write-Host " "
	Write-Host "This script populates the gidNumber on a group to allow its usage with UNIX/Linux systems."
	Write-Host "The alias of the group is passed to the script as an argument."
	Write-Host " "
	Write-Host "Usage: \SetGIDNUmber.ps1 groupname"
	Write-Host " " 	
	Exit
	}

Import-Module ActiveDirectory

#Create hashtables to hold members
$memberht = @{}
$memberuidht = @{}

#Set variables
$blnused = $true
$sam = $args[0]
$ADSever = "aoexadcdecaf001.decaf.expecn.com"

#Get gidNumbers from AD and add them to a hashtable
$gidtable = @{}
$allgid = Get-ADGroup -Properties:gidNumber -Filter {(gidNumber -like '*')} -Server $ADSever
Foreach ($gid in $allgid)
	{
	$gidtable.Add($gid.samAccountName,$gid.gidNumber)
	}

#Get the next available gid
$maxgid = $gidtable.GetEnumerator() | Sort-Object Value -Descending | Select -First 1
$nextgid = $maxgid.Value



#Retrieve the group if it exists
try 
	{
	$group = Get-ADGroup -Identity $sam -Properties gidNumber -Server $ADSever
	}
catch	
	{
	Write-Host "There is no group named $sam in the Decaf domain"
	exit
	}
	
$groupgid = $group.gidNumber

If ($groupgid -eq $null)
	{

	Do	
		{
			$nextgid = $nextgid + 1
			$blnused = $gidtable.ContainsValue($nextgid)
		}
		While ($blnused -eq $true)

	Write-Host "Applying gidNumber $nextgid to $sam..."
	Set-ADGroup $sam -Replace @{gidNumber="$nextgid"} -Server $ADSever 
	
	Write-Host "Updating memberUID attribute with group members..."
	
	$members = Get-ADGroupMember -Identity $sam -Server $ADSever 
	$memberuids = $group.memberuid

	
	#If there aren't any members of the group, there's nothing to do, so exit
	If ($members -eq $null)
		{
		Write-Host "No members found in $sam"
		Exit
		}

	#Populate a hashtable with the group members
	Foreach ($member in $members)
		{
		$memberht.Add($member.samAccountName,$member.samAccountName)
		}

	#Populate a hashtable with the users in the memberUID attribute
	Foreach ($memberuid in $memberuids)
		{
		$memberuidht.Add($memberuid,$memberuid)
		}
	
	#Check if group members are included in the memberUID attribute
		Foreach ($member in $members)
			{
			$ismember = $memberuidht.ContainsKey($member.samAccountName)
			If ($ismember -eq $false)
				{
            			$membersam = $member.samAccountName
				Write-Host "Adding $membersam to memberUID attribute for $sam..."
            			Set-ADGroup -Identity $group -Add @{memberUID=$membersam} -Server $ADSever
				}
			}
		
		Write-Host "Done!"
		
	
	}
Else
	{
	Write-Host "gidNumber $groupgid is already assigned to $sam"
	}