#!/bin/bash

sudo apt install -y nfs-kernel-server
sudo mkdir -p /mnt/nfs-general
sudo chown nobody:nogroup /mnt/nfs-general
sudo chmod 777 /mnt/nfs-general
sudo sed -i '/\/mnt\/nfs-general/d' /etc/exports
sudo sed -i '$a /mnt/nfs-general   192.168.100.0/24(rw,sync,no_subtree_check)' /etc/exports
sudo exportfs -a
sudo systemctl restart nfs-kernel-server
sudo systemctl enable nfs-kernel-server

for nodes in 192.168.100.11 192.168.100.12; do
ssh $nodes 'bash -s' << EOT
sudo apt install -y nfs-common
sudo mkdir -p /mnt/nfs-general
sudo mount 192.168.100.10:/mnt/nfs-general /mnt/nfs-general
sudo sed -i '/\/mnt\/nfs-general/d' /etc/fstab
sudo sed -i '\$a 192.168.100.10:/mnt/nfs-general    /mnt/nfs-general   nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0' /etc/fstab
EOT
done
