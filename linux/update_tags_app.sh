#!/bin/bash

# Script help
show_help() {
    echo "Usage: $0 [region] [application]"
    echo
}

region=$1
app=$2

# Validate argument count
if [ "$#" -ne 2 ]; then
    echo "Wrong number of arguments!!!!"
    echo ""
    show_help
    exit 1
fi

for i in $(cat servers.txt); do
    aws ec2 create-tags --region=${1} --resources ${i} --tags "Key=Application,Value=${2}"
done
