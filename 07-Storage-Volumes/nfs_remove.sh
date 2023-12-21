#!/bin/bash

sudo sed -i '/\/mnt\/nfs-general/d' /etc/exports
sudo rm -rf /mnt/nfs-general
sudo apt remove -y nfs-kernel-server

for nodes in 192.168.100.11 192.168.100.12; do
ssh $nodes 'bash -s' << EOT
sudo sed -i '/\/mnt\/nfs-general/d' /etc/fstab
sudo umount 192.168.100.10:/mnt/nfs-general
sudo rm -rf /mnt/nfs-general
sudo apt remove -y nfs-common
EOT
done
