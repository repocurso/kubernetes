#!/bin/bash

NODOS="master node1 node2"
for nodo in $NODOS; do
  echo "========== $nodo =========="
  #export CRI_SOCKET=$(kubectl get node $nodo -o=jsonpath='{.metadata.annotations.kubeadm\.alpha\.kubernetes\.io/cri-socket}')
  #ssh $nodo if [ "$CRI_SOCKET" == "" ]; then sudo "kubeadm reset --cri-socket $CRI_SOCKET<<<y"; else sudo "kubeadm reset --force <<<y"; fi
  #ssh $nodo sudo kubeadm reset --cri-socket $CRI_SOCKET <<< y
  ssh $nodo sudo kubeadm reset --force <<< y
  ssh $nodo sudo apt-get -qq purge -y kubeadm kubectl kubelet kubernetes-cni kube*   
  ssh $nodo sudo apt-get -qq autoremove -y 
  ssh $nodo sudo rm -fr /etc/kubernetes/; sudo rm -fr ~/.kube/; sudo rm -fr /var/lib/etcd; sudo rm -rf /var/lib/cni/
  ssh $nodo sudo systemctl daemon-reload
done
