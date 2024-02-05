#!/bin/bash

# Definición de variables de entorno
NODES="master node1 node2"

for NODE in $NODES; do
  echo "========== $NODE =========="
  # Instalar la nueva versión de kubeadmin
  ssh $NODE "sudo apt-mark unhold kubeadm && sudo apt-get update && sudo apt-get install -y kubeadm=1.23.17-00 --allow-downgrades && sudo apt-mark hold kubeadm"
  # Verificar las versiones a instalar
  if [ $NODE == master ]; then sudo kubeadm upgrade plan; fi
  # Realizar la actualización de la nueva versión de kubeadmin
  if [ $NODE == master ]; then sudo kubeadm upgrade apply v1.23.17 <<< y; fi
  # Actualizar la configuración de kubelet
  if [ $NODE != master ]; then ssh $NODE sudo kubeadm upgrade node; fi
  # Operación drain en el worker para no recibir workloads
  kubectl drain $NODE --ignore-daemonsets
  # Actualizar las herramientas kubelet y kubectl
  ssh $NODE "sudo apt-mark unhold kubelet kubectl && sudo apt-get update && sudo apt-get install -y kubelet=1.23.17-00 kubectl=1.23.17-00 && sudo apt-mark hold kubelet kubectl"
  # Reiniciar el servicio de kubelet en el worker
  ssh $NODE sudo systemctl daemon-reload
  ssh $NODE sudo systemctl restart kubelet
  # Habilitar que el nodo worker pueda recibir workloads
  kubectl uncordon $NODE
done

