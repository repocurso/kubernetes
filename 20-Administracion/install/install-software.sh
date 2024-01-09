#!/bin/bash

# Variables de entorno
KUBERNETES_VERSION=$1

# Agregar el repositorio de kubernetes
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo add-apt-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main"

# Instalar kubelet, kubeadm y kubectl
sudo apt-get update && sudo apt-get install -y docker-ce=5:19.03.9~3-0~ubuntu-focal docker-ce-cli=5:19.03.9~3-0~ubuntu-focal kubelet=${KUBERNETES_VERSION}-00 kubeadm=${KUBERNETES_VERSION}-00 kubectl=${KUBERNETES_VERSION}-00

# Modificar la configuración de kubelet agregando la IP del master
export IPADDR=$(ip -4 addr show eth1 | grep inet |  awk '{print $2}' | cut -f1 -d/)
sudo sed -i '/\[Service\]/a Environment="KUBELET_EXTRA_ARGS=--node-ip='$IPADDR'"' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo systemctl daemon-reload
sudo systemctl restart kubelet
