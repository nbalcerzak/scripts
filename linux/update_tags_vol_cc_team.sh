#!/bin/bash

# Script help
show_help() {
    echo "Usage: $0 [region]"
    echo
}

region=$1

for i in $(cat volumes.txt); do
    aws ec2 create-tags --region=${1} --resources ${i} --tags
    "Key=CostCenter,Value=90534"
    "Key=Team,Value=REO Logging Platform"
    "Key=Application,Value=splunkcloud-storage"
    "Key=AssetProtectionLevel,Value=99"
    "Key=Brand,Value=eCommerce Platform"
done
