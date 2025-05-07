#!/bin/bash

# Script help
show_help() {
    echo "Usage: $0 [region]"
    echo
}

region=$1

for i in $(cat vpce_services.txt); do
    aws ec2 create-tags --region=${1} --resources ${i} --tags
    "Key=CostCenter,Value=90534"
    "Key=Team,Value=REO Logging Platform"
    "Key=AssetProtectionLevel,Value=99"
    "Key=Brand,Value=eCommerce Platform"
done
