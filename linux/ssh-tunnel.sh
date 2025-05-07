#!/bin/bash

##########
# SSH Tunneling:
# Update the three variables below and execute script. It will open your default browser with the URL.
##########

user=test
local_ip=10.142.14.246
remote_ip=12.34.56.78
pem_file=/path/to/your/pem/file

ssh -N -L 4443:${local_ip}:443 -i ${pem_file} ${user}@${remote_ip}

start https://localhost:4443
