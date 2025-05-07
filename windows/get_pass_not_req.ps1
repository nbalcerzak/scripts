Get-ADUser -Filter 'useraccountcontrol -band 32' -Properties useraccountcontrol


foreach ($user in desktop\users.txt)
    {
        net user $user /passwordreq:yes /domain
    }