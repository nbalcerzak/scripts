#!/bin/bash

# Script help
show_help() {
    echo "Usage: $0 [region] [costcenter] [team]"
    echo
}

region=$1
cost_center=$23
team=$3

# Validate argument count
if [ "$#" -ne 3 ]; then
    echo "Wrong number of arguments!!!!"
    echo ""
    show_help
    exit 1
fi

for i in $(cat servers.txt); do
    aws ec2 create-tags --region=${1} --resources ${i} --tags "Key=CostCenter,Value=${2}" "Key=Team,Value=${3}"
done
