#!/bin/bash

# This script is intended to copy files to a remote storage location based off the indexer name using ssh keys for rsync and cleans source directories.
# Created by Nate Balcerzak 06/09/2017

# Get Indexer short hostname
host_name=$(hostname -s)

# Destination server check based off of indexer name
case $host_name in
*001 | *002)
    remote_server=server001
    ;;
*003 | *004)
    remote_server=server002
    ;;
*005 | *006)
    remote_server=server003
    ;;
*007 | *008)
    remote_server=server004
    ;;
*009 | *010)
    remote_server=server005
    ;;
esac

# Local file directory
local_dir=/data2/splunkarchive/

# Remote file directory
remote_dir="$remote_server":/archive/SplunkArchive/$(hostname -s)/

# Comment this section out if you do NOT want to archive files and uncomment the section below that to do a dry run
#rsync -hvrPte 'ssh -i /home/s-splbackup/.ssh/id_rsa' "$local_dir" "$remote_dir"

# Uncomment this section if you want to perform a dry run of the rsync without making any changes
rsync --dry-run -hvrPte 'ssh -i /home/s-splbackup/.ssh/id_rsa' "$local_dir" "$remote_dir"

# Clean sub folders
#rm -rf "$local_dir"/*/*
