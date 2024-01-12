#!/bin/bash

# Instalación de packages
sudo apt install -y net-tools tree jq unzip dos2unix sshpass

# Creación y copia de la clave SSH
ssh-keygen -q -t rsa -f ~/.ssh/id_rsa -N "" <<< y > /dev/null

# Modificación del archivo /etc/hosts
sudo sed -i '/master/d; /node1/d; /node2/d' /etc/hosts
sudo sed -i '$a 192.168.100.10\tmaster.local\tmaster\n192.168.100.11\tnode1.local\tnode1\n192.168.100.12\tnode2.local\tnode2' /etc/hosts

# Copia de la clave SSH y acceso
for NODE in master node1 node2; do 
  NODE_IP=$(awk -v node="$NODE" '$0 ~ node {print $1}' /etc/hosts);
  sshpass -f prepare.txt ssh-copy-id -o StrictHostKeyChecking=no $NODE_IP -f
  sshpass -f prepare.txt | ssh -o StrictHostKeyChecking=no $NODE exit;
done

