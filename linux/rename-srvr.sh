#!/bin/bash

OLD_NAME=$(hostname)

#get today's date for backing up the files
TDATE=$(date "%m-%d-%y")

#check to make sure there is a new name supplied on the command line
NEW_NAME=$1
echo "$1"
if [ -z "$NEW_NAME" ]; then
    echo "You have to supply the new name!!!"
    echo "QUITTING!!"
    exit 1
fi

#Check verion, only looking for 6.X at ths time
VERSION=$(grep 6 /etc/redhat-release)
if [ -z "$VERSION" ]; then
    echo "This script will not work on this version of the OS!"
    echo "Please rename this server manually."
fi

OLD_SHORT_NAME=$(hostname | cut -d"." -f1)
NEW_SHORT_NAME=$(( cut -d "." -f 1 ) <<< $NEW_NAME)

#Once all the checks above pass, make backups of the files and rename the server
cp /etc/hosts /etc/hosts.${TDATE}.pre_rename
cp /etc/sysconfig/network /etc/sysconfig/network.${TDATE}.pre_rename
cp /etc/pam_ldap.conf /etc/pam_ldap.conf.${TDATE}.pre_rename

LINK=$(ls -l /etc/openldap/cacerts | grep ^l | grep $(hostname).crt | awk '{print $9}')
cd /etc/openldap/cacerts
tar cvf ${OLD_NAME}.${TDATE}.openldap.certs.tar ./??*
mv ./${OLD_NAME}.crt ./${NEW_NAME}.crt
mv ./${OLD_NAME}.key ./${NEW_NAME}.key

rm -rf ${LINK}
ln -s ${NEW_NAME}.crt ${LINK}

SPLUNK=$(rpm -qa splunk)

if [ -n "$SPLUNK" ]; then
    cp /opt/splunkforwarder/etc/system/local/inputs.conf /opt/splunkforwarder/etc/system/local/inputs.conf.${TDATE}.pre_rename
    sed -i -e 's/'$OLD_NAME'/'${NEW_NAME}'/ ' /opt/splunkforwarder/etc/system/local/inputs.conf
    cp /opt/splunkforwarder/etc/system/local/server.conf /opt/splunkforwarder/etc/system/local/server.conf.${TDATE}.pre_rename
    sed -i -e 's/'$OLD_NAME'/'${NEW_NAME}'/ ' /opt/splunkforwarder/etc/system/local/server.conf
fi

sed -i -e 's/'${OLD_NAME}'/'${NEW_NAME}'/g' /etc/hosts
sed -i -e 's/'${OLD_SHORT_NAME}'/'${NEW_SHORT_NAME}'/g' /etc/hosts
sed -i -e 's/'${OLD_NAME}'/'${NEW_NAME}'/' /etc/sysconfig/network
sed -i -e 's/'${OLD_NAME}'/'${NEW_NAME}'/' /etc/pam_ldap.conf
sed -i -e 's/'${OLD_NAME}'/'${NEW_NAME}'/' /etc/motd
if [ -a /usr/openv/netbackup/bp.conf ]; then
    sed -i -e 's/'$OLD_SHORT_NAME'/'${NEW_SHORT_NAME}'/ ' /usr/openv/netbackup/bp.conf
    cat /usr/openv/netbackup/bp.conf
fi

sleep 10

#change the hostname without a reboot
hostname ${NEW_NAME}

#Get the location of the server: ch or ph
WHERE=$(hostname | cut -b 1-2)
DOMAIN=$(hostname | awk -F. '{print $2}')
if [ "$WHERE" == ch and "DOMAIN" == domain1 ]; then
    rm -rf /var/lib/puppet/ssl/*
    wget -O /etc/puppet/puppet.conf http://10.184.1.209/pub/apps/puppet/puppet.conf
    puppet agent -t

elif [ "$WHERE" == ph and "DOMAIN" == domain1 ]; then
    rm -rf /var/lib/puppet/ssl/*
    wget -O /etc/puppet/puppet.conf http://10.208.0.87/pub/apps/puppet/puppet.conf
    puppet agent -t

elif [ "$WHERE" == ch and "DOMAIN" == domain2 ]; then
    rm -rf /var/lib/puppet/ssl/*
    wget -O /etc/puppet/puppet.conf http://10.184.1.209/pub/apps/puppet/puppet.conf
    puppet agent -t

elif [ "$WHERE" == ph and "DOMAIN" == domain2 ]; then
    rm -rf /var/lib/puppet/ssl/*
    wget -O /etc/puppet/puppet.conf http://10.208.0.87/pub/apps/puppet/puppet.conf
    puppet agent -t

elif [ "$WHERE" == ch and "DOMAIN" == domain3 ]; then
    rm -rf /var/lib/puppet/ssl/*
    wget -O /etc/puppet/puppet.conf http://10.185.60.56/pub/apps/puppet/puppet.conf
    puppet agent -t

elif [ "$WHERE" == ph and "DOMAIN" == domain3 ]; then
    rm -rf /var/lib/puppet/ssl/*
    wget -O /etc/puppet/puppet.conf http://10.206.16.26/pub/apps/puppet/puppet.conf
    puppet agent -t

elif [ "$WHERE" == ch and "DOMAIN" == domain4 ]; then
    rm -rf /var/lib/puppet/ssl/*
    wget -O /etc/puppet/puppet.conf http://10.185.60.56/pub/apps/puppet/puppet.conf
    puppet agent -t

elif [ "$WHERE" == ph and "DOMAIN" == domain4 ]; then
    rm -rf /var/lib/puppet/ssl/*
    wget -O /etc/puppet/puppet.conf http://10.206.16.26/pub/apps/puppet/puppet.conf
    puppet agent -t

elif [ "$WHERE" == ch and "DOMAIN" == domain5 ]; then
    rm -rf /var/lib/puppet/ssl/*
    wget -O /etc/puppet/puppet.conf http://10.185.60.56/pub/apps/puppet/puppet.conf
    puppet agent -t

elif [ "$WHERE" == ph and "DOMAIN" == domain5 ]; then
    rm -rf /var/lib/puppet/ssl/*
    wget -O /etc/puppet/puppet.conf http://10.206.16.26/pub/apps/puppet/puppet.conf
    puppet agent -t

elif [ "$WHERE" == ch and "DOMAIN" == domain6 ]; then
    rm -rf /var/lib/puppet/ssl/*
    wget -O /etc/puppet/puppet.conf http://10.185.60.56/pub/apps/puppet/puppet.conf
    puppet agent -t

elif [ "$WHERE" == ph and "DOMAIN" == domain6 ]; then
    rm -rf /var/lib/puppet/ssl/*
    wget -O /etc/puppet/puppet.conf http://10.206.16.26/pub/apps/puppet/puppet.conf
    puppet agent -t

fi
