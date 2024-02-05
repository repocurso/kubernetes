#!/bin/bash

# Definición de las variables de entorno

export MASTER_IP="192.168.100.10"
export MASTER_IP="master"
export WORKER_IP="192.168.100.11 192.168.100.12"
export WORKER_IP="node1 node2"
export KUBERNETES_VERSION="1.27.2-00"
export CRIO_VERSION="1.26"

# Instalar software kubernetes
for nodo in $MASTER_IP $WORKER_IP; do
  echo "========== $nodo =========="
  ssh $nodo 'bash -s' < install-common.sh $KUBERNETES_VERSION $CRIO_VERSION
done

# Inicializar el clúster de kubernetes
ssh $MASTER_IP 'bash -s' < install-master.sh 

# Unir los nodos workers al clúster
for nodo in $WORKER_IP; do
  echo "========== $nodo =========="
  ssh $nodo 'bash -s' < install-worker.sh 
done
