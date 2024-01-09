#!/bin/bash

# Instalación de packages

sudo apt install -y tree
sudo apt install -y jq
sudo apt install -y unzip

# Creación y copia de la clave SSH

ssh-keygen -q -t rsa -f ~/.ssh/id_rsa -N "" <<< y
ssh-copy-id 192.168.100.10 -f 
ssh-copy-id 192.168.100.11 -f 
ssh-copy-id 192.168.100.12 -f

# Modificación del archivo /etc/hosts

sudo sed -i '/master/d; /node1/d; /node2/d' /etc/hosts
sudo sed -i '$a 192.168.100.10\tmaster.local\tmaster\n192.168.100.11\tnode1.local\tnode1\n192.168.100.12\tnode2.local\tnode2' /etc/hosts
