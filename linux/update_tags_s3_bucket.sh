#!/bin/bash

for i in $(cat buckets.txt); do
    aws s3api put-bucket-tagging --bucket ${i} --tagging
    "TagSet=[ 
	  {Key=Application,Value=splunkcloud-storage}, 
	  {Key=AssetProtectionLevel,Value=99}, 
	  {Key=Brand,Value=eCommerce Platform}, 
	  {Key=CostCenter,Value=90534}, 
	  {Key=Team,Value=REO Logging Platform}
  ]"
done
