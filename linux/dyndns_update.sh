#!/bin/bash

NS=172.31.67.177
HOST=$(hostname)
IPV4=$(hostname -I)
ZONE=local_domain.net

## If you want to use a key file for authentication, uncomment the next line and change the path to point to your key
#KEY=/home/nbalcerzak/Ksub.dyn.example.com. 157 22656.key

## If you want to use a key file for authentication, uncomment the next line
#nsupdate -k $KEY -v << EOF

## If you do not want to use a key file for authentication, comment out the next line only
nsupdate -g <<EOF
server $NS
zone $ZONE
update delete $HOST A
update add $HOST 3600 A $IPV4
show
send
EOF
