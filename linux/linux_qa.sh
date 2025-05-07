#!/bin/bash

cd ~
HOST=$(hostname -s)
DATE=$(date %Y%m%d%H%M%S)
TYPE="qa"
IFS=$'n'

echo -e "n -------------- SERVER MN/SN -------------" >/root/$HOST-$DATE-$TYPE.log
dmidecode -t 1 | grep Manufacturer >>/root/$HOST-$DATE-$TYPE.log
dmidecode -t 1 | grep Product >>/root/$HOST-$DATE-$TYPE.log
dmidecode -t 1 | grep Serial >>/root/$HOST-$DATE-$TYPE.log

echo -e "n -------------- KERNEL VERSION ---------------" >>/root/$HOST-$DATE-$TYPE.log
rpm -qa | grep kernel >>/root/$HOST-$DATE-$TYPE.log

echo -e "n -------------- OS VERSION ---------------" >>/root/$HOST-$DATE-$TYPE.log
cat /etc/redhat-release >>/root/$HOST-$DATE-$TYPE.log

echo -e "n -------------- PROCESSORS ---------------" >>/root/$HOST-$DATE-$TYPE.log
dmesg | grep processors >>/root/$HOST-$DATE-$TYPE.log

echo -e "n ---------------- MEMORY -----------------" >>/root/$HOST-$DATE-$TYPE.log
dmesg | grep 'System RAM' >>/root/$HOST-$DATE-$TYPE.log

echo -e "n ---------------- DATE -----------------" >>/root/$HOST-$DATE-$TYPE.log
date >>/root/$HOST-$DATE-$TYPE.log
if [ $(grep UTC /etc/adjtime) ]; then
    echo "UTC - True" >>/root/$HOST-$DATE-$TYPE.log
else
    echo "UTC - False" >>/root/$HOST-$DATE-$TYPE.log
fi

echo -e "n --------------- AD GROUPS ---------------" >>/root/$HOST-$DATE-$TYPE.log
for i in $(tail -1 /etc/sssd/sssd.conf | cut -d "=" -f2 | sed "s/['',]/n/g" | grep -v unix); do
    getent group $i >>/root/$HOST-$DATE-$TYPE.log
    EXITSTAT=$?
    if [[ $EXITSTAT != 0 ]]; then
        echo "ERROR - $i is missing gid" >>/root/$HOST-$DATE-$TYPE.log
    fi
    echo >>/root/$HOST-$DATE-$TYPE.log
done

echo -e "n --------------- SSSD SIMPLE ALLOWED ---------------" >>/root/$HOST-$DATE-$TYPE.log
tail /etc/sssd/sssd.conf | grep simple_allow_groups >>/root/$HOST-$DATE-$TYPE.log

echo -e "n --------------- SUDOERS ACCESS ---------------" >>/root/$HOST-$DATE-$TYPE.log
cat /etc/sudoers.d/admins | grep % >>/root/$HOST-$DATE-$TYPE.log

echo -e "n --------------- PUPPET CONFIG ---------------" >>/root/$HOST-$DATE-$TYPE.log
tail /etc/puppet/puppet.conf | grep reporturl >>/root/$HOST-$DATE-$TYPE.log

echo -e "n --------------- COBBLER REPO ---------------" >>/root/$HOST-$DATE-$TYPE.log
cat /etc/yum.repos.d/cobbler-config.repo | grep baseurl >>/root/$HOST-$DATE-$TYPE.log
cat /etc/yum.repos.d/cobbler-config.repo | grep mirrorlist >>/root/$HOST-$DATE-$TYPE.log

echo -e "n -------------- PACKAGE UPDATES --------------" >>/root/$HOST-$DATE-$TYPE.log
yum check-update &>/dev/null
YUMCHECK=$?
if [ $YUMCHECK == 100 ]; then
    echo -e "Package updates are requirednPlease run 'sudo yum update -y'" >>/root/$HOST-$DATE-$TYPE.log
elif [ $YUMCHECK == 0 ]; then
    echo "All packages are up to date" >>/root/$HOST-$DATE-$TYPE.log
else
    echo "Error checking for updates" >>/root/$HOST-$DATE-$TYPE.log
fi

echo -e "n ----------- ETHERNET ADAPTERS -----------" >>/root/$HOST-$DATE-$TYPE.log
ifconfig | grep -v Scope | grep -v RX | grep -v TX | grep -v collisions | grep -v Interrupt >>/root/$HOST-$DATE-$TYPE.log
echo >>/root/$HOST-$DATE-$TYPE.log

echo -e "n ---------------- MTU SIZE ----------------" >>/root/$HOST-$DATE-$TYPE.log
sysctl -a | egrep "tcp_base|tcp_mtu" >>/root/$HOST-$DATE-$TYPE.log

echo -e "n ------------------ FQDN -----------------" >>/root/$HOST-$DATE-$TYPE.log
hostname >>/root/$HOST-$DATE-$TYPE.log

if [ -e /proc/net/bonding/bond0 ]; then
    echo -e "n ------------- BONDING MODE --------------" >>/root/$HOST-$DATE-$TYPE.log
    cat /proc/net/bonding/bond0 | grep -v "Failure|queue|HW|Driver|Delay" >>/root/$HOST-$DATE-$TYPE.log
fi

echo -e "n ---------------- GATEWAY ----------------" >>/root/$HOST-$DATE-$TYPE.log
netstat -r | grep default >>/root/$HOST-$DATE-$TYPE.log

echo -e "n ---------------- FUSION IO VERSION ----------------" >>/root/$HOST-$DATE-$TYPE.log
lspci | grep -i fusion >>/root/$HOST-$DATE-$TYPE.log

echo -e "n ---------------- FUSION IO STATUS ----------------" >>/root/$HOST-$DATE-$TYPE.log
yum list installed fio-status &>/dev/null
EXITSTAT=$?
if [ $EXITSTAT -eq 0 ]; then
    fio-status >>/root/$HOST-$DATE-$TYPE.log
fi

echo -e "n ---------------- TANIUM CLIENT ----------------" >>/root/$HOST-$DATE-$TYPE.log
if [ $(yum list installed | grep TaniumClient) ]; then
    printf "TaniumClient is installedn" >>/root/$HOST-$DATE-$TYPE.log
else
    printf "TaniumClient not installedn" >>/root/$HOST-$DATE-$TYPE.log
fi

if [ $(cat /etc/centos-release | cut -d" " -f3 | cut -d"." -f1) == 6 ]; then
    service TaniumClient status >>/root/$HOST-$DATE-$TYPE.log
else
    systemctl status taniumclient | grep Active >>/root/$HOST-$DATE-$TYPE.log
fi

if [ -e /opt/Tanium/TaniumClient/TaniumClient.ini ]; then
    if [ $(grep -m 1 10.184.80.50 /opt/Tanium/TaniumClient/TaniumClient.ini) ]; then
        printf "TaniumClient.ini - PASSn" >>/root/$HOST-$DATE-$TYPE.log
    elif [ $(grep -m 1 10.186.52.73 /opt/Tanium/TaniumClient/TaniumClient.ini) ]; then
        printf "TaniumClient.ini - PASSn" >>/root/$HOST-$DATE-$TYPE.log
    else
        printf "TaniumClient.ini - FAILEDn" >>/root/$HOST-$DATE-$TYPE.log
    fi
else
    printf "TaniumClient.ini Not Found!n" >>/root/$HOST-$DATE-$TYPE.log
fi

if [ -e /opt/Tanium/TaniumClient/tanium.pub ]; then
    printf "tanium.pub - PASSn" >>/root/$HOST-$DATE-$TYPE.log
else
    printf "tanium.pub - FAILEDn" >>/root/$HOST-$DATE-$TYPE.log
fi

echo -e "n -------------- HARD DRIVES --------------" >>/root/$HOST-$DATE-$TYPE.log
lsblk | grep -v 'fd0' >>/root/$HOST-$DATE-$TYPE.log

echo -e "n -------------- FILE SYSTEMS -------------" >>/root/$HOST-$DATE-$TYPE.log
df -h >>/root/$HOST-$DATE-$TYPE.log

echo -e "n -------------- RESOLV.CONF --------------" >>/root/$HOST-$DATE-$TYPE.log
cat /etc/resolv.conf >>/root/$HOST-$DATE-$TYPE.log

echo -e "n -------------- CMDB.XML -----------------" >>/root/$HOST-$DATE-$TYPE.log
cat /etc/CMDB.xml >>/root/$HOST-$DATE-$TYPE.log

echo -e "n ------------------ END ------------------" >>/root/$HOST-$DATE-$TYPE.log
less /root/$HOST-$DATE-$TYPE.log
