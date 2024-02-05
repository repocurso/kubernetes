#!/bin/bash

# Definición de las variables de entorno

export MASTER_IP="192.168.100.10"
export MASTER_IP="master"
export WORKER_IP="192.168.100.11 192.168.100.12"
export WORKER_IP="node1 node2"
export KUBERNETES_VERSION="1.23.12"
export KUBEADM_TOKEN="vgue3w.ur6f4viisj3nazk1"

# Instalar software kubernetes 
for nodo in $MASTER_IP $WORKER_IP; do
  echo "========== $nodo =========="
  ssh $nodo 'bash -s' < install-software.sh $KUBERNETES_VERSION
done

# Inicializar el clúster de kubernetes 
sudo kubeadm init --kubernetes-version ${KUBERNETES_VERSION} --apiserver-advertise-address ${MASTER_IP} --pod-network-cidr 10.244.0.0/16 --token ${KUBEADM_TOKEN}
export KUBEADM_TOKEN_SHA=sha256:$(openssl x509 -in /etc/kubernetes/pki/ca.crt -noout -pubkey | openssl rsa -pubin -outform DER 2>/dev/null | sha256sum | cut -d' ' -f1)

# Copiar el archivo kubeconfig en el entorno del usuario
if [ -d ~/.kube ]; then
  rm -rf ~/.kube
fi
mkdir ~/.kube
sudo cp -Rf /etc/kubernetes/admin.conf ~/.kube/config
sudo chown -R $(id -u):$(id -g) ~/.kube

# Instalar calico
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml

# Unir los nodos workers al clúster
for nodo in $WORKER_IP; do
  echo "========== $nodo =========="
  ssh $nodo sudo kubeadm join ${MASTER_IP}:6443 --token ${KUBEADM_TOKEN} --discovery-token-ca-cert-hash ${KUBEADM_TOKEN_SHA}
done  
