#!/bin/bash
#
# Setup for Node servers

set -euxo pipefail

export CONFIG_PATH="/vagrant/curso/cri-o/configs"

sudo /bin/bash ${CONFIG_PATH}/join.sh -v

#sudo -i -u vagrant bash << EOF
#whoami
#mkdir -p ${HOME}/.kube
#sudo cp -i ${CONFIG_PATH}/config ${HOME}/.kube/
#sudo chown $(id -u):$(id -g) ${HOME}/.kube/config
#export NODENAME=$(hostname -s)
#kubectl label node ${NODENAME} node-role.kubernetes.io/role=worker
#EOF

mkdir -p ${HOME}/.kube
sudo cp -i ${CONFIG_PATH}/config ${HOME}/.kube/ <<<y
sudo chown $(id -u):$(id -g) ${HOME}/.kube/config
export NODENAME=$(hostname -s)
kubectl label node ${NODENAME} node-role.kubernetes.io/worker=worker
