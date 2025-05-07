<#
.SYNOPSIS
    This script gathers data needed to validate QA of the built servers
.NOTES
    File Name  : FullQA.ps1
    Author     : Kevin Fraley; Joel Kaasa; Jeremy Murrell
.EXAMPLE
    FullQA.ps1 -HostName ServerName <- Returns for the specified server
    FullQA.ps1 –FileName FilePath <- Returns a list for all servers loaded in the file. (One Hostname per line)
    FullQA.ps1 <- Uses the default location of current path \servers.txt. Returns a list for all servers loaded in the file. (One Hostname per line)
.PARAMETERS
    -HostName (Optional)
    -FilePath (Optional)
#>
#region Parameters

Param(
    [String]
    $HostName = "Default",
    [String]
    $FilePath = ((split-path -parent $MyInvocation.MyCommand.Definition) + "\servers.txt")
    )

#endregion

#region Error Handling

$erroractionpreference = "SilentlyContinue"

#endregion

#region Global Variables

$global:biosInfo = $null
$global:processorInfo = $null
$global:computerInfo = $null
$global:networkInfo = $null
$global:logicalDiskInfo = $null
$global:secviceInfo = $null
$global:OSInfo = $null
$global:LocalAdministrators = $null
$global:MTU = $null
$global:DNSPTRCheck = $null
$global:PageFileSize = $null
$global:timeZoneInfo = $null
$global:localTimeInfo = $null
$global:portStatusRDC = $null
$global:arrayComputers = $null
$global:activeDirectoryOU = $null
$global:taniumInfo = $null
$global:cmdbInfo = $null
$global:cmdb = $null

#endregion

#region Functions

Function GatherData {
    PARAM (
        [Parameter(Position=0, Mandatory=$true)]
        $Computer
    )

    BEGIN{}

    PROCESS
    {
        try
        {
            $global:biosInfo = Get-WmiObject -ComputerName $Computer Win32_Bios | Select SMBIOSBIOSVersion,Name,SerialNumber,ReleaseDate
            $global:processorInfo = Get-WmiObject -ComputerName $Computer Win32_Processor | Select Name,NumberOfCores,NumberOfLocalProcessors,NumberOfLogicalProcessors
            $global:computerInfo = Get-WmiObject -ComputerName $Computer Win32_ComputerSystem | Select Domain,Manufacturer,Model,Name,TotalPhysicalMemory
            $global:networkInfo = Get-WmiObject -ComputerName $Computer Win32_NetworkAdapterConfiguration | ? {$_.IPEnabled}
            #$global:logicalDiskInfo = Get-WmiObject -ComputerName $Computer Win32_LogicalDisk -Filter 'DriveType=3' | Select DeviceID,Size
            $global:secviceInfo = Get-WmiObject -ComputerName $Computer Win32_Service | Select Name
            $global:OSInfo = Get-WmiObject -ComputerName $Computer Win32_OperatingSystem | Select Caption,CSDVersion
            $global:PageFileSize = Get-WmiObject -ComputerName $Computer Win32_PageFileusage | Select AllocatedBaseSize
            $global:timeZoneInfo = Get-WmiObject -ComputerName $Computer Win32_TimeZone | Select Caption,Bias
            $global:localTimeInfo = Get-WmiObject -ComputerName $Computer Win32_LocalTime | Select Month,Day,Year,Hour,Minute
            $global:portStatusRDC = TestPort $Computer "3389"
            $global:cmdbInfo = Test-Path "\\$Computer\c$\CMDB.xml"
            $global:cmdb = [xml](Get-Content "\\$Computer\c$\CMDB.xml")
            #$global:biosver = (systeminfo /s $Computer | findstr BIOS)
            #$global:LocalAdministrators = invoke-command -ComputerName $Computer -ScriptBlock {net localgroup administrators | where {$_ -and $_ -notmatch "command completed successfully"} | select -skip 4}
            $global:MTU = invoke-command -ComputerName $Computer -ScriptBlock {netsh interface ipv4 show interfaces | select -skip 2}
            $global:DNSPTRCheck = invoke-command -ComputerName $Computer -ScriptBlock {hostname | nslookup}
            #$global:LocalAdministrators = Get-CimInstance -ClassName win32_group -Filter "name = 'administrators'" | Get-CimAssociatedInstance -Association win32_groupuser | Select Caption
            Return $true
        }
        catch
        {
            [system.Exception]
            Return $false
        }
    }
    END{}
}

Function ValidateServerConnection {
    PARAM (
        [Parameter(Position=0, Mandatory=$true)]
        $Computer
        )
    Begin{}

    Process
    {
        $result = Test-Connection $Computer -Count 1 -Quiet
        Return $result
    }
    END{}
}

Function TestPort {
    PARAM
    (
    [Parameter(Position=0, Mandatory=$true)]
    $Computer,
    [Parameter(Position=1, Mandatory=$true)]
    $Port
    )
    
    BEGIN{}
    
    PROCESS
    {
        $Socket = New-Object Net.Sockets.TcpClient 
        
        $ErrorActionPreference = 'SilentlyContinue'
        
        $Socket.Connect($Computer, $Port)   
        
        $ErrorActionPreference = 'Continue'
        
        if ($Socket.Connected) 
        {
            $Socket.Close()
            $Socket = $null
            Return $true
        }
        else 
        {
            $Socket = $null
            Return $false
        }
    }
    
    END{}
    
}

Function GetActivationStatus {
[CmdletBinding()]
    param(
        [Parameter(Position=0, Mandatory=$true)]
        $Computer
    )
    
    BEGIN{}
    
    PROCESS {
        try {
            $wpa = Get-WmiObject SoftwareLicensingProduct -ComputerName $Computer `
            -Filter "ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f'" `
            -Property LicenseStatus -ErrorAction Stop
        } catch {
            $status = New-Object ComponentModel.Win32Exception ($_.Exception.ErrorCode)
            $wpa = $null
        }
        $out = New-Object psobject -Property @{
            ComputerName = $Computer;
            Status = [string]::Empty;
        }
        if ($wpa) {
            :outer foreach($item in $wpa) {
                switch ($item.LicenseStatus) {
                    0 {$out.Status = "Unlicensed"}
                    1 {$out.Status = "Licensed"; break outer}
                    2 {$out.Status = "Out-Of-Box Grace Period"; break outer}
                    3 {$out.Status = "Out-Of-Tolerance Grace Period"; break outer}
                    4 {$out.Status = "Non-Genuine Grace Period"; break outer}
                    5 {$out.Status = "Notification"; break outer}
                    6 {$out.Status = "Extended Grace"; break outer}
                    default {$out.Status = "Unknown value"}
                }
            }       
        } 
        else 
        {
            $out.Status = $status.Message
        }       
        
        $wpa = $null
        
        Return $out.Status
    }
    
    END{}
}

Function ValidateStarupParameters {
    
    BEGIN{}
    
    PROCESS
    {
        if ($HostName -ne "Default")
        {
            $global:arrayComputers = $HostName
            return $true
        }
        else
        {
            if ((Test-Path -Path $FilePath) -eq $True)
            {
                $global:arrayComputers = Get-Content $FilePath
                return $true
            }
            else
            {
                Write-Host -ForegroundColor Red "ERROR!! File $FilePath Not Found Closing Script"
                return $false               
            }
        }
    }
    
    END{}
}

Function ValidateRunningService {
    PARAM 
    (
    [Parameter(Position=0, Mandatory=$true)]
    $serviceName
    )  

    BEGIN{}
    
    PROCESS {
    
    foreach ($service in $global:secviceInfo)
    {
        If ($service.Name -eq $serviceName)
        {
            return $true
        }
    }
    
    return $false
    
    }
    
    END{}

}

Function GetActiveDirectoryOU {
    PARAM 
    (
    [Parameter(Position=0, Mandatory=$true)]
    $Computer,
    [Parameter(Position=1, Mandatory=$true)]
    $Domain
    )

    BEGIN{}
    
    PROCESS 
    {
        $a = Get-ADComputer -Identity $Computer -Server $Domain

        Return $a.DistinguishedName
    }
    
    END{}

}

#endregion


ValidateStarupParameters


#region Get Data and add to excel

Count for data placment by rows
$intRow = 2

foreach ($strComputer in $global:arrayComputers)
{
    If ((ValidateServerConnection $strComputer) -eq $true)
    {   
        Write-Host "Starting to gather data for server $strComputer"
        
        GatherData $strComputer
        Write-Host "Host Name - " $global:computerInfo.Name
        Write-Host "Domain - " $global:computerInfo.Domain
        Write-Host "OS Version - " $global:OSInfo.Caption
        Write-Host "Service Pack - " $global:OSInfo.CSDVersion
        Write-Host "Page File Size - " $global:PageFileSize.AllocatedBaseSize
        Write-Host "Local Administrators - " $global:LocalAdministrators
        Write-Host "Machine Type - " ($global:computerInfo.Manufacturer + " " + $global:computerInfo.Model)
        Write-Host "Serial Number - " $global:biosInfo.SerialNumber
        Write-Host $global:biosver
        Write-Host "Logical Processors - " $global:ProcessorInfo.NumberOfLogicalProcessors
        Write-Host "Processor Cores - " $global:ProcessorInfo.NumberOfCores
        Write-Host "Time Zone - " $global:timeZoneInfo.Caption
        Write-Host "DST - " ($global:timeZoneInfo.Bias -eq -60)
        Write-Host "Date - " ($global:localTimeInfo.Month.ToString() + "\" + $global:localTimeInfo.Day.ToString() + "\" + $global:localTimeInfo.Year.ToString())
        Write-Host "Time - " ($global:localTimeInfo.Hour.ToString() + ":" + $global:localTimeInfo.Minute.ToString())
        Write-Host "Splunk - " (ValidateRunningService "SplunkForwarder")
        Write-Host "SMS Agent - " (ValidateRunningService "CcmExec")
        Write-Host "McAfee - " (ValidateRunningService "mcshield")
        Write-Host "BladeLogic - " (ValidateRunningService "RSCDsvc")
        Write-Host "WANSync - " (ValidateRunningService "CAARCserveRHAEngine")
        Write-Host "NetBackup - " (ValidateRunningService "NetBackup INET Daemon")
        Write-Host "Tanium Client - " (ValidateRunningService "Tanium Client")
        Write-Host "Windows RDC - " $global:portStatusRDC
        Write-Host "CMDB File - " ($global:cmdbInfo)
        Write-Host "CMDB Owner - "$global:cmdb.CmdbOwner.Owner.name
        Write-Host "CMDB Application - " ($global:cmdb.CmdbOwner.Application.name)
        Write-Host "CMDB Modified on - " ($global:cmdb.CmdbOwner.Modified.date) " by " ($global:cmdb.CmdbOwner.Modified.person)
        Write-Host "Memory - " ([System.Math]::Round(($global:computerInfo.TotalPhysicalMemory)/1GB).ToString() + "GB")
        #Write-Host "Active Directory OU - " (GetActiveDirectoryOU $global:computerInfo.Name $global:computerInfo.Domain)
        Write-Host "Windows Activation Status - " (GetActivationStatus $global:computerInfo.Name)
        Write-Host "MTU Size - " $global:MTU
        Write-Host "DNS PTR Check - " $global:DNSPTRCheck
        
        
        #region Format Excel for disk drives
        # This is necessary to format excel incase there are mutipule drives or mutipule network connections. 
        $externalCount = $intRow
        foreach ($drive in $global:logicalDiskInfo)
        {
            #$wrkSheet1.Cells.Item($externalCount,19) = $drive.DeviceID + "_" + ([System.Math]::Round(($drive.Size)/1GB).ToString() + "GB")
            Write-Host "Logical Disk Info - " ($drive.DeviceID + "_" + ([System.Math]::Round(($drive.Size)/1GB).ToString() + "GB"))
            
            $externalCount++        
        }
        #endregion
        
        $maxCount = $externalCount
        
        #region Format Excel for network adaptors
        $externalCount = $intRow
        foreach ($adapter in $global:networkInfo)
        {
            $index = $adapter.Index
            
            $adapterName = Get-WmiObject Win32_NetworkAdapter -ComputerName $strComputer -Filter "index = $index" | Select NetConnectionID,Name
            
            if ($adapterName.Name)
            {
                #$wrkSheet1.Cells.Item($externalCount,21) = $adapterName.NetConnectionID    
                Write-Host "NIC Name - " $adapterName.NetConnectionID   
            }
            else
            {
                #$wrkSheet1.Cells.Item($externalCount,21) = "Primary Team"
                Write-Host "NIC Name - Primary Team" 
            }
            
            #$wrkSheet1.Cells.Item($externalCount,20) = $adapterName.Name
            Write-Host "Network Card Type - " $adapterName.Name
            #$wrkSheet1.Cells.Item($externalCount,22) = $adapter.IPAddress
            Write-Host "IP Address - " $adapter.IPAddress
            #$wrkSheet1.Cells.Item($externalCount,23) = $adapter.IPSubnet
            Write-Host "Subnet Mask - " $adapter.IPSubnet
            #$wrkSheet1.Cells.Item($externalCount,24) = $adapter.DefaultIPGateway
            Write-Host "Default Gateway - " $adapter.DefaultIPGateway
            #$wrkSheet1.Cells.Item($externalCount,25) = $adapter.DNSServerSearchOrder[0]
            Write-Host "Primary DNS - " $adapter.DNSServerSearchOrder[0]
            #$wrkSheet1.Cells.Item($externalCount,26) = $adapter.DNSServerSearchOrder[1]
            Write-Host "Secondary DNS - " $adapter.DNSServerSearchOrder[1]
            #$wrkSheet1.Cells.Item($externalCount,27) = $adapter.MACAddress
            Write-Host "MAC Address - " $adapter.MACAddress
            
            $externalCount++
        }
        
        #Set Row Count based upon rows used for drives and network adaptors 
        If ($externalCount -ge $maxCount)
        {
            $intRow = $externalCount
        }
        else
        {
            $intRow = $maxCount
        }
        #endregion
        
        Write-Host "Gather data for server $strComputer complete"
        Write-Host " "
        Write-Host " "
        Write-Host " "
        Write-Host " "
    }
    else
    {
        #Server did not reply to ping request
        #$wrkSheet1.Cells.Item($intRow,1) = $strComputer + " Unable to access system. Check Ping and Credentials"
        Write-Host $strComputer " Unable to access system. Check Ping and Credentials"
        $intRow++
    }
    
    
}

#endregion

#region Show Resaults when done filling data

#Autofit the text so you can see all of the data
#$wrksheetformat.EntireColumn.AutoFit()
#$wrksheetformat.EntireRow.AutoFit()

#Make excel visible
#$excel.visible = $True

#endregion