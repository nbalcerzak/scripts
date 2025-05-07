#!/bin/bash

# Define FQDN of server(s) to bootstrap
servers=$(cat servers.txt)

# Define username
user="USERNAME"

# Define password variable
pass=$(gpg -d -q '.mypass.gpg')

# Bootstrap node to Chef Manage server
for fqdn in $servers; do
    knife bootstrap windows winrm $fqdn -N $fqdn -x $user -P $pass
done
