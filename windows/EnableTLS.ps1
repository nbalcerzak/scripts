<#
This Script updates the current registry settings for encryption
 - Protocols
 - Cipthers
 - Hashes
 - KeyExchangeAlgorithms
 #>

#Create Reg Key and Disable Protocol
Function CreateProtocolDisable($RegKey)
{
  New-Item "$RegKey" -Force | Out-Null
  
  New-Item "$RegKey\Client" -Force | Out-Null
  New-ItemProperty -path "$RegKey\Client" -name "Enabled" -value 0 -PropertyType "DWord" -Force | Out-Null
  New-ItemProperty -path "$RegKey\Client" -name "DisabledByDefault" -value 1 -PropertyType "DWord" -Force | Out-Null

  New-Item "$RegKey\Server" -Force | Out-Null
  New-ItemProperty -path "$RegKey\Server" -name "Enabled" -value 0 -PropertyType "DWord" -Force | Out-Null
  New-ItemProperty -path "$RegKey\Server" -name "DisabledByDefault" -value 1 -PropertyType "DWord" -Force | Out-Null
}

Function CreateProtocolEnable($RegKey)
{
  New-Item "$RegKey" -Force | Out-Null
  
  New-Item "$RegKey\Client" -Force | Out-Null
  New-ItemProperty -path "$RegKey\Client" -name "Enabled" -value '0xffffffff' -PropertyType "DWord" -Force | Out-Null
  New-ItemProperty -path "$RegKey\Client" -name "DisabledByDefault" -value 0 -PropertyType "DWord" -Force | Out-Null

  New-Item "$RegKey\Server" -Force | Out-Null
  New-ItemProperty -path "$RegKey\Server" -name "Enabled" -value '0xffffffff' -PropertyType "DWord" -Force | Out-Null
  New-ItemProperty -path "$RegKey\Server" -name "DisabledByDefault" -value 0 -PropertyType "DWord" -Force | Out-Null
}


Function CheckProtocolDisable($RegKey)
{
  If (-Not (Test-Path -path "$RegEntry\Client"))
  {
    New-Item "$RegKey\Client" -Force | Out-Null
    New-ItemProperty -path "$RegKey\Client" -name "Enabled" -value 0 -PropertyType "DWord" -Force | Out-Null
    New-ItemProperty -path "$RegKey\Client" -name "DisabledByDefault" -value 1 -PropertyType "DWord" -Force | Out-Null 
  }
  else
  {
    New-ItemProperty -path "$RegKey\Client" -name "Enabled" -value 0 -PropertyType "DWord" -Force | Out-Null
    New-ItemProperty -path "$RegKey\Client" -name "DisabledByDefault" -value 1 -PropertyType "DWord" -Force | Out-Null
  }

  If (-Not (Test-Path -path "$RegEntry\Server"))
  {
    New-Item "$RegKey\Server" -Force | Out-Null 
    New-ItemProperty -path "$RegKey\Server" -name "Enabled" -value 0 -PropertyType "DWord" -Force | Out-Null
    New-ItemProperty -path "$RegKey\Server" -name "DisabledByDefault" -value 1 -PropertyType "DWord" -Force | Out-Null
  }
  else
  {
    New-ItemProperty -path "$RegKey\Server" -name "Enabled" -value 0 -PropertyType "DWord" -Force | Out-Null
    New-ItemProperty -path "$RegKey\Server" -name "DisabledByDefault" -value 1 -PropertyType "DWord" -Force | Out-Null
  }
}

Function CheckProtocolEnable($RegKey)
{
  If (-Not (Test-Path -path "$RegEntry\Client"))
  {
    New-Item "$RegKey\Client" -Force | Out-Null
    New-ItemProperty -path "$RegKey\Client" -name "Enabled" -value '0xffffffff' -PropertyType "DWord" -Force | Out-Null
    New-ItemProperty -path "$RegKey\Client" -name "DisabledByDefault" -value 0 -PropertyType "DWord" -Force | Out-Null 
  }
  else
  {
    New-ItemProperty -path "$RegKey\Client" -name "Enabled" -value '0xffffffff' -PropertyType "DWord" -Force | Out-Null
    New-ItemProperty -path "$RegKey\Client" -name "DisabledByDefault" -value 0 -PropertyType "DWord" -Force | Out-Null
  }

  If (-Not (Test-Path -path "$RegEntry\Server"))
  {
    New-Item "$RegKey\Server" -Force | Out-Null 
    New-ItemProperty -path "$RegKey\Server" -name "Enabled" -value '0xffffffff' -PropertyType "DWord" -Force | Out-Null
    New-ItemProperty -path "$RegKey\Server" -name "DisabledByDefault" -value 0 -PropertyType "DWord" -Force | Out-Null
  }
  else
  {
    New-ItemProperty -path "$RegKey\Server" -name "Enabled" -value '0xffffffff' -PropertyType "DWord" -Force | Out-Null
    New-ItemProperty -path "$RegKey\Server" -name "DisabledByDefault" -value 0 -PropertyType "DWord" -Force | Out-Null
  }
}

$HiveRoot = "Registry::HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL"

#Set Protocols
$Section = "Protocols"
$Protocols = @("Multi-Protocol Unified Hello","PCT 1.0","SSL 2.0","SSL 3.0","TLS 1.0","TLS 1.1","TLS 1.2")

foreach ($Protocol in $Protocols)
{
  $RegEntry = "$HiveRoot\$Section\$Protocol"

  If (($Protocol -eq "TLS 1.1") -or ($Protocol -eq "TLS 1.2"))
  {
    If (-Not (Test-Path -path $RegEntry))
    {
      CreateProtocolEnable $RegEntry
    }
    else
    {
      CheckProtocolEnable $RegEntry
    }
  }
}

#Update Ciphers
$Section = "Ciphers"
$Ciphers = @("AES 128/128","AES 256/256","DES 56/56","NULL","RC2 128/128","RC2 40/128","RC2 56/128","RC4 128/128","RC4 40/128","RC4 56/128","RC4 64/128","Triple DES 168")

foreach ($Cipher in $Ciphers)
{
  $RegEntry = "$HiveRoot\$Section\$Cipher"

  If (($Cipher -eq "AES 128/128") -or ($Cipher -eq "AES 256/256") -or ($Cipher -eq "Triple DES 168"))
  {
    $key = (Get-Item HKLM:\).OpenSubKey('SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers', $true).CreateSubKey($Cipher)
    $key.SetValue('Enabled', 0xffffffff, 'DWord')
    $key.close()
  }
}


#Update Hashes
$Section = "Hashes"
$Hashes = @("MD5","SHA","SHA256","SHA384","SHA512")

foreach ($Hash in $Hashes)
{
  $RegEntry = "$HiveRoot\$Section\$Hash"

  If (($Hash -eq "SHA256") -or ($Hash -eq "SHA384") -or ($Hash -eq "SHA512"))
  {
    If (-Not (Test-Path -path $RegEntry))
    {
      New-Item "$RegEntry" -Force | Out-Null
      New-ItemProperty -path "$RegEntry" -name "Enabled" -value '0xffffffff' -PropertyType "DWord" -Force | Out-Null
    }
    else
    {
      New-ItemProperty -path "$RegEntry" -name "Enabled" -value '0xffffffff' -PropertyType "DWord" -Force | Out-Null
    }
  }
}

#Get KeyExchangeAlgorithms
$Section = "KeyExchangeAlgorithms"
$KeyExchanges = @("Diffie-Hellman","ECDH","PKCS")

foreach ($KeyExchange in $KeyExchanges)
{
  $RegEntry = "$HiveRoot\$Section\$KeyExchange"

  If (-Not (Test-Path -path $RegEntry))
  {
    New-Item "$RegEntry" -Force | Out-Null
    New-ItemProperty -path "$RegEntry" -name "Enabled" -value '0xffffffff' -PropertyType "DWord" -Force | Out-Null
  }
  else
  {
    New-ItemProperty -path "$RegEntry" -name "Enabled" -value '0xffffffff' -PropertyType "DWord" -Force | Out-Null
  }
}
