#################################################################################
##
## Created by: Nate Balcerzak
## Date Created: 05/09/2019
##
## DESCRIPTION:
## Installs the splunkforwarder for windows machines and sets the deployment server.
##
#################################################################################

## Script Variables
$app_name = "changeme"
$deplt_server = "changeme"

#################################################################################
##                          DO NOT MODIFY BELOW HERE                           ##
#################################################################################

## Check to see if we are in AWS before we execute anything.
$aws_test = (Invoke-WebRequest -Uri '169.254.169.254/latest/meta-data/hostname').statuscode
if (!($aws_test -eq 200)) {Write-Host "This script cannot be executed outside of an AWS environment. EXITING NOW!" Break}

## Set script variables.
$version = "7.1.6"
$build = "8f009a3f5353"
$aws_account = (Invoke-WebRequest -Uri '169.254.169.254/latest/meta-data/identity-credentials/ec2/info').Content | ConvertFrom-Json | Select-Object AccountId
$aws_account_id = $aws_account -replace ‘[@{AccountId=}]’,''
$ec2_instance_id = (Invoke-WebRequest -Uri '169.254.169.254/latest/meta-data/instance-id').Content
$hostname = (Invoke-WebRequest -Uri '169.254.169.254/latest/meta-data/hostname').Content
$installer = "splunkforwarder-$version-$build-x64-release.msi"
$install_dir = "C:\Splunk\"
$install_url = "http://installers.lmf-corp.kepler.expedia.biz/windows"
$dl_dir = "C:\temp"
$splunkcmd = $install_dir + "bin\splunk.exe"
$staticsystem = $install_dir + "etc\system\"
$staticlocal = $staticsystem + "local\"
$staticlocal_in = $staticlocal + "inputs.conf"
$staticlocal_dc = $staticlocal + "deploymentclient.conf"

## Creating required directories.
if (!(Test-Path -Path $dl_dir)) {new-item -ItemType Directory -Path $dl_dir}
if (!(Test-Path -Path $staticsystem)) {new-item -ItemType Directory -Path $staticsystem}
if (!(Test-Path -Path $staticlocal)) {new-item -ItemType Directory -Path $staticlocal}

# [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

## Download and install the UF.
try {
    if (!(Test-Path -Path $dl_dir\$installer)) {Invoke-RestMethod -Method GET -Uri "$install_url/$installer" -OutFile "$dl_dir\$installer"}
    Write-Host "Installing ${installer} ..."
    Invoke-Command -ScriptBlock { & cmd /c "msiexec.exe /i $dl_dir\$installer" INSTALLDIR=$install_dir LAUNCHSPLUNK=1 AGREETOLICENSE=Yes DEPLOYMENT_SERVER=$deplt_server:8089 /qb /log C:\temp\splunkforwarder.log /quiet}
    Write-Host "Installation of ${installer} has completed."
} catch {
    Write-Host "Installation of ${installer} has returned the following error $_"
    Throw "Aborted installation of ${installer} has returned $_"
}

## Remove default inputs.conf file.
Write-Host "Removing default $staticlocal_in."
Remove-Item $staticlocal_in

## Create new inputs.conf file with correct information.
Write-Host "Creating new $staticlocal_in file."
new-item -path $staticlocal_in -ItemType File
Add-Content -Path $staticlocal_in -Value "[default]"
Add-Content -Path $staticlocal_in -Value "host=${app_name}-${hostname}"
Add-Content -Path $staticlocal_in -Value "_meta=aws_account_id::${aws_account_id}"
Add-Content -Path $staticlocal_in -Value "_meta=ec2_instance_id::${ec2_instance_id}"

## Create new deploymentclient.conf file with correct information.
Write-Host "Creating new $staticlocal_dc file."
new-item -path $staticlocal_dc -ItemType File
Add-Content -Path $staticlocal_dc -Value "[deployment-client]"
Add-Content -Path $staticlocal_dc -Value "clientName=${app_name}-${hostname}"
Add-Content -Path $staticlocal_dc -Value ""
Add-Content -Path $staticlocal_dc -Value "[target-broker:deploymentServer]"
Add-Content -Path $staticlocal_dc -Value "targetUri=${deplt_server}:8089"

## Restart the Splunkforwarder to pick up all changes.
Write-Host "Restarting the Splunkforwarder now."
& $splunkcmd "restart"
