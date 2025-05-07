#!/bin/bash

# Splunk AppInspect API Calls

# API Credentials
username="usernamehere"
password="passwordhere"


# GET call for credentials
curl -X GET -u "$username" "https://api.splunk.com/2.0/rest/login/splunk"


# POST call for app submission
curl -X POST \
	-H "Authorization: bearer <token>" \
	-H "Cache-Control: no-cache" \
	-F "app_package=@\"/path/to/splunk/app.tgz\"" \
	-F "included_tags=cloud" \
	--url "https://appinspect.splunk.com/v1/app/validate"

# GET status of the request
curl -X GET "https://appinspect.splunk.com/v1/app/validate/status/{request_id}"
