#################################################################################
##
## Change admincount for termed domain user accounts
##
## Created by: Nate Balcerzak
## Date Created: 01/22/2018
##
## DESCRIPTION:
## This script will loop through users in a specific OU and change the admincount flag from 1 to 0.
##
## INSTRUCTIONS:
## Please change the "$sbase" path to the OU in the domain that you are running it in.
## It's very important that you have the right DN path populated for the script to work.
## You must also run this script for any subdomains within a TLD, please see instructions below.
##
## DN EXAMPLES:
## $sbase = "OU=Term,DC=expeso,DC=com" ## MUST be run from a machine in the target DN - "expeso.com"
## $sbase = "OU=Term,DC=ch,DC=expeso,DC=com" ## MUST be run from a machine in the target DN - "ch.expeso.com"
## $sbase = "OU=Term,DC=ph,DC=expeso,DC=com" ## MUST be run from a machine in the target DN - "ph.expeso.com"
##
#################################################################################

# Change the search base to equal where you want to change the admincount of the users located within
$sbase = "OU=Term,DC=ch,DC=expeso,DC=com"

# Get a list of users to change the admincount variable on
$users = Get-ADUser -ldapfilter "(objectclass=user)" -searchbase $sbase

# Get domain values
$domain = Get-ADDomain
$domainPdc = $domain.PDCEmulator
$domainDn = $domain.DistinguishedName

# HashTable to be used for the reset
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
        #Changes AdminCount back to "not set";
        Get-ADuser $user.DistinguishedName -Properties "admincount" | Set-ADUser -Remove $replaceAttributeHashTable  -Server $domainPdc
        #Change security and commit
        $sec.SetAccessRuleProtection($isProtected, $preserveInheritance)
        $ou.psbase.commitchanges()
    }
}