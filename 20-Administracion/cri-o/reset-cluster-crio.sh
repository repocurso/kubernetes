#!/bin/bash

NODOS="master node1 node2"
for nodo in $NODOS; do
  echo "========== $nodo =========="
  ssh $nodo sudo kubeadm reset --cri-socket unix:///var/run/containerd/containerd.sock --cri-socket unix:///var/run/crio/crio.sock --force <<< y
  ssh $nodo sudo apt-get -qq update
  ssh $nodo sudo systemctl stop crio --now
  ssh $nodo sudo systemctl disable crio --now
  ssh $nodo sudo apt-get -qq purge -y cri-o cri-o-runc
  ssh $nodo "if [ -f /usr/lib/systemd/system/crio.service ]; then sudo rm -f /usr/lib/systemd/system/crio.service; fi"
  ssh $nodo sudo apt-get -qq purge -y kubeadm kubectl kubelet kubernetes-cni kube*   
  ssh $nodo sudo apt-get -qq autoremove -y 
  ssh $nodo sudo rm -fr /etc/kubernetes/; sudo rm -fr ~/.kube/; sudo rm -fr /var/lib/etcd; sudo rm -rf /var/lib/cni/
  ssh $nodo sudo rm -fr /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:*.list
  ssh $nodo sudo systemctl daemon-reload
done
