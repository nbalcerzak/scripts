#########################
#
#
#
#
#########################

# Set Variable users to get all User objects within OU specified in searchbase
$users = Get-ADUser -ldapfilter "(objectclass=user)" -searchbase "OU=Term,DC=ch,DC=expeso,DC=com"
$CSVPath = "c:\temp\admincount.csv"
$list = @()

ForEach($user in $users)
{
    # Binding the users to DS
    $ou = [ADSI]("LDAP://" + $user)
    $sec = $ou.psbase.objectSecurity

    if ($sec.get_AreAccessRulesProtected()) #If the account is protected. The statement returns true and runs the script block.
    {
	    $list += get-aduser $user.DistinguishedName -Properties "admincount" | select Name,
        @{N="AdminCount"; E={$_.AdminCount}}
    }
}
$list | Export-Csv $CSVPath -NoTypeInformation








$users = Get-ADUser -ldapfilter "(objectclass=user)" -searchbase "OU=Term,DC=ch,DC=expeso,DC=com"

#Get domain values
$domain = Get-ADDomain
$domainPdc = $domain.PDCEmulator
$domainDn = $domain.DistinguishedName

#HashTable to be used for the reset
$replaceAttributeHashTable = New-Object HashTable
$replaceAttributeHashTable.Add("AdminCount",0)

$isProtected = $false ## allows inheritance
$preserveInheritance = $true ## preserve inheritance rules


ForEach($user in $users)
{
    # Binding the users to DS
    $ou = [ADSI]("LDAP://" + $user)
    $sec = $ou.psbase.objectSecurity

    if ($sec.get_AreAccessRulesProtected())
    {
        #Changes AdminCount back to &lt;not set&gt;
        Get-ADuser $user.DistinguishedName -Properties "admincount" | Set-ADUser -Remove $replaceAttributeHashTable  -Server $domainPdc
        #Change security and commit
        $sec.SetAccessRuleProtection($isProtected, $preserveInheritance)
        $ou.psbase.commitchanges()
    }
}