#!/bin/bash

# Definición de las variables de entorno

export MASTER_IP="192.168.100.10"
export HOSTNAMES_IP="192.168.100.11 192.168.100.12 $MASTER_IP"
export HOSTNAMES="node1 node2 master"
export CONTAINERD_VERSION="1.7.11"
export CONTAINERD_FILE="containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz"
export CONTAINERD_FILE_URL="https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/${CONTAINERD_FILE}"
export DOWNLOAD_DIR="~/download/containerd/"

# Cambiar el Container Runtime 
for nodo in $HOSTNAMES; do
  echo "========== $nodo =========="
  # Preparar el nodo a modificar
  ssh $MASTER_IP kubectl drain $nodo --ignore-daemonsets --delete-emptydir-data
  # Detener kubelet , docker daemon y containerd
  ssh $nodo sudo systemctl stop kubelet
  ssh $nodo sudo systemctl disable docker.service --now
  ssh $nodo sudo systemctl stop containerd
  #ssh $nodo sudo apt-get purge -y docker-ce docker-ce-cli
  # Instalar containerd
  ssh $nodo "rm -rf $DOWNLOAD_DIR && mkdir -p $DOWNLOAD_DIR"  
  ssh $nodo "cd $DOWNLOAD_DIR && curl --silent -LO $CONTAINERD_FILE_URL"
  ssh $nodo sudo tar Cxzvf /usr/local ${DOWNLOAD_DIR}${CONTAINERD_FILE}
  ssh $nodo "cd $DOWNLOAD_DIR && curl --silent -LO https://raw.githubusercontent.com/containerd/containerd/main/containerd.service"
  ssh $nodo sudo cp ${DOWNLOAD_DIR}containerd.service /lib/systemd/system/
  ssh $nodo sudo systemctl daemon-reload
  ssh $nodo sudo systemctl enable --now containerd
  ssh $nodo sudo mkdir -p /etc/containerd
  ssh $nodo "containerd config default | sudo tee /etc/containerd/config.toml" 2> /dev/null
  ssh $nodo sudo systemctl restart --now containerd
  # Instalar runc
  ssh $nodo "cd $DOWNLOAD_DIR && curl --silent -LO https://github.com/opencontainers/runc/releases/download/v1.1.11/runc.amd64"
  ssh $nodo "cd $DOWNLOAD_DIR && sudo install -m 755 runc.amd64 /usr/local/sbin/runc"
  # Instalar complementos CNI
  ssh $nodo "cd $DOWNLOAD_DIR && curl --silent -LO https://github.com/containernetworking/plugins/releases/download/v1.4.0/cni-plugins-linux-amd64-v1.4.0.tgz"
  ssh $nodo "cd $DOWNLOAD_DIR && sudo mkdir -p /opt/cni/bin && sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.4.0.tgz"
  # Configurar kubelet para usar containerd
  ssh $nodo 'echo KUBELET_KUBEADM_ARGS=\"--network-plugin=cni --pod-infra-container-image=k8s.gcr.io/pause:3.6 --container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock\" | sudo tee /var/lib/kubelet/kubeadm-flags.env'
  # Reiniciar kubelet
  ssh $nodo sudo chmod +rx /run/containerd/containerd.sock /run/containerd/containerd.sock.ttrpc
  ssh $nodo sudo systemctl restart --now kubelet
  # Editar la configuración del nodo
  if [ $nodo == "master" ]; then sleep 45; fi
  ssh $MASTER_IP kubectl annotate node $nodo --overwrite kubeadm.alpha.kubernetes.io/cri-socket=unix:///var/run/containerd/containerd.sock
  # Eliminar el motor de docker
  ssh $nodo sudo apt-get purge -y docker-ce docker-ce-cli
  ssh $nodo sudo rm -r /etc/docker /var/lib/docker /var/lib/dockershim
  # Poner operativo el nodo
  ssh $MASTER_IP "sleep 10 && kubectl uncordon $nodo"
done
