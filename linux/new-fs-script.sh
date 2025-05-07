#!/bin/bash

PARTS=$(cat /proc/partitions | grep sdl)
if [[ -n ${PARTS} ]]; then
    for i in {b..o}; do
        echo $i
        /sbin/mkfs.ext4 -F -m 0 -i 524288 /dev/sd$i
    done
    for i in {1..14}; do mkdir /data$i; done
    for i in {b..o}; do
        echo $i
        tune2fs -c 0 /dev/sd$i
    done
    df -h
    echo "All drives have been formatted and mounted up."
else
    for i in {2..14}; do hpacucli ctrl all show config | grep "bay $i" | awk '{print $2}' >>/var/tmp/drives; done
    for p in $(cat /var/tmp/drives); do hpacucli ctrl slot=0 create type=ld drives=$p raid=0; done
    for i in {b..o}; do
        echo $i
        /sbin/mkfs.ext4 -F -m 0 -i 524288 /dev/sd$i
    done
    for i in {1..14}; do mkdir /data$i; done
    for i in {b..o}; do
        echo $i
        tune2fs -c 0 /dev/sd$i
    done
fi

THERE=$(grep sdl /etc/fstab)

if [[ -z "$THERE" ]]; then
    cp /etc/fstab /etc/PRE.fstab
    echo "/dev/sdb         /data1               ext4    defaults,noatime        1 2" >>/etc/fstab
    echo "/dev/sdc         /data2               ext4    defaults,noatime        1 2" >>/etc/fstab
    echo "/dev/sdd         /data3               ext4    defaults,noatime        1 2" >>/etc/fstab
    echo "/dev/sde         /data4               ext4    defaults,noatime        1 2" >>/etc/fstab
    echo "/dev/sdf         /data5               ext4    defaults,noatime        1 2" >>/etc/fstab
    echo "/dev/sdg         /data6               ext4    defaults,noatime        1 2" >>/etc/fstab
    echo "/dev/sdh         /data7               ext4    defaults,noatime        1 2" >>/etc/fstab
    echo "/dev/sdi         /data8               ext4    defaults,noatime        1 2" >>/etc/fstab
    echo "/dev/sdj         /data9               ext4    defaults,noatime        1 2" >>/etc/fstab
    echo "/dev/sdk         /data10               ext4    defaults,noatime        1 2" >>/etc/fstab
    echo "/dev/sdl         /data11               ext4    defaults,noatime        1 2" >>/etc/fstab
    echo "/dev/sdm         /data12               ext4    defaults,noatime        1 2" >>/etc/fstab
    echo "/dev/sdn         /data13               ext4    defaults,noatime        1 2" >>/etc/fstab
    echo "/dev/sdo         /data14               ext4    defaults,noatime        1 2" >>/etc/fstab
fi

mount -a
