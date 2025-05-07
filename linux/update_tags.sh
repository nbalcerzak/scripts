#!/bin/bash

# Script help
show_help() {
    echo "Usage: $0 [region] [application] [costcenter] [team] [update tags]"
    echo
    echo "   [region] should be the region you want to check or update in aws."
    echo
    echo "   [application] should be the Application tag associated with your application."
    echo
    echo "   [costcenter] must be set to your applications costcenter metadata."
    echo
    echo "   [team] should be your team name in the same metadata for the app."
    echo
    echo "   [update tags] should be a yes or no only."
    echo "   This will update the servers listed in the servers.txt file."
    echo
}

read -p "Enter Your Region: " region
read -p "Enter Your Application Name: " application
read -p "Enter Your Cost Center Number: " cost_center
read -p "Enter Your Team Name: " team

ec2-list() {
    aws ec2 describe-instances --region=${region}
    --filters Name=tag-key,Values=Name
    --query 'Reservations[*].Instances[*].{Instance:InstanceId,AZ:Placement.AvailabilityZone,Name:Tags[?Key==`Name`]|[0].Value,CostCenter:Tags[?Key==`CostCenter`]|[0].Value,Application:Tags[?Key==`Application`]|[0].Value,Team:Tags[?Key==`Team`]|[0].Value}'
    --output table
}

update-tags() {
    for i in $(cat servers.txt); do
        aws ec2 create-tags --region=${region} --resources ${i} --tags "Key=Application,Value=${application}" "Key=CostCenter,Value=${cost_center}" "Key=Team,Value=${5}"
    done
}

ec2-list

# Check to see if tags should be updated for the servers in the list
read -p "Do You Want To Update Your Tags For The Servers Listed?: " update_tags

if [ $update_tags == "yes" ]; then
    update-tags
else
    exit
fi
