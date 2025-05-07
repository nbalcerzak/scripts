#!/bin/bash

### Script Variables ###
servers=$(cat server-list.txt)
sshpass=$(gpg -d -q .sshpass.gpg)
file=/opt/splunk/etc/datetime.xml
file_bak=/opt/splunk/etc/datetime.xml.bak
new_file=http://server1.domain.com/splunkcloud/hot-fixes/datetime.xml

### Script Actions ###
for i in ${servers}; do
    echo "${i}: " >>output.txt
    sshpass -p ${sshpass} ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -tttq ${i} "echo ${sshpass} | sudo -S mv ${file} ${file_bak}; echo ${sshpass} | sudo -S wget -O ${file} ${new_file}; echo ${sshpass} | sudo -S chown splunk.splunk ${file}; echo ${sshpass} | sudo -S ls -l /opt/splunk/etc | grep datetime; " >>output.txt
done
