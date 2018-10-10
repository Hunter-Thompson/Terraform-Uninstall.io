#!/bin/bash

while [ ! -d /sys/block/xvdb ]; do exit; done
if [ ! -d /sys/block/xvdb/xvdb1 ]; then
    echo -e "g\nn\np\n1\n\n\nw" | sudo fdisk /dev/xvdb
    sudo mkfs.ext4 /dev/xvdb1
fi

if [ ! -d /Data ]; then
    sudo mkdir /Data
fi

if grep '/dev/vdb1' /etc/fstab; then
    exit
else
    sudo echo "/dev/vdb1 /Data ext4 0 0" | sudo tee --append /etc/fstab > /dev/null
    sudo mount -a
fi

