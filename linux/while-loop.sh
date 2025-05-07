#!/bin/bash

while true; do
    curl -k -X POST -H "Content-Type:application/json" -H "Authorization: Splunk <splunk token>" -d '{"event": "Nate says hello!", "sourcetype": "batch-test-tool"}' "https://<splunk-hec-url>/services/collector/event"
    sleep 1
done
