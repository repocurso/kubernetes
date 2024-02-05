#!/bin/bash

# ==================================================
# Configurar nodos workers
# ==================================================

set -euxo pipefail

MASTER_IP="192.168.100.10"
MASTER_IP="65.109.2.44"
NODENAME=$(hostname -s)

# --------------------------------------------------
# Unir el nodo al clúster de Kuberenetes
# --------------------------------------------------

CONFIG_PATH="$HOME/download/crio-configs"

if [ -d $CONFIG_PATH ]; then
  rm -rf $CONFIG_PATH
fi
mkdir -p $CONFIG_PATH

scp $MASTER_IP:$CONFIG_PATH/* $CONFIG_PATH

sudo /bin/bash ${CONFIG_PATH}/join-command.sh -v

# --------------------------------------------------
# Otras operaciones
# --------------------------------------------------

mkdir -p ${HOME}/.kube
sudo cp -i ${CONFIG_PATH}/config ${HOME}/.kube/ <<<y
sudo chown $(id -u):$(id -g) ${HOME}/.kube/config
kubectl label node ${NODENAME} node-role.kubernetes.io/worker=worker

