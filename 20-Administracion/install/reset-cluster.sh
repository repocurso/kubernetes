#!/bin/bash

NODOS="master node1 node2"
for nodo in $NODOS; do
  echo "========== $nodo =========="
  ssh $nodo sudo kubeadm reset --force <<< y
  ssh $nodo sudo apt-get purge -y kubeadm kubectl kubelet kubernetes-cni kube*   
  ssh $nodo sudo apt-get autoremove -y 
  ssh $nodo sudo rm -fr /etc/kubernetes/; sudo rm -fr ~/.kube/; sudo rm -fr /var/lib/etcd; sudo rm -rf /var/lib/cni/
  ssh $nodo sudo systemctl daemon-reload
done
