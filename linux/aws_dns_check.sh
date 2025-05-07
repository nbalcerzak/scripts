#!/bin/bash

aws_region=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F '{print $4}')
echo AWS Region: $aws_region
ec2_mac=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/ 2>&1 | awk -v RS='r' '{print substr($0,1,17)}')
echo EC2 MAC: $ec2_mac
aws_vpc_id=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/$ec2_mac/vpc-id)
echo AWS VPC: $aws_vpc_id

security_context=$1

dplt_vpce_dns="splunk-deployment-${aws_vpc_id}.${aws_region}.${security_context}.net"

dns_check=$(dig $dplt_vpce_dns A short)

if [ -n "$dns_check" ]; then
    vpce_dns="true"
    echo VPCE Connection: $vpce_dns
else
    vpce_dns="false"
    echo VPCE Connection: $vpce_dns
fi
