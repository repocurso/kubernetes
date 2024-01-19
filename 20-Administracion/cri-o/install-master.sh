#!/bin/bash

# ==================================================
# Configurar el nodo Control Plane (master) 
# ==================================================

set -euxo pipefail

MASTER_IP="192.168.100.10"
NODENAME=$(hostname -s)
POD_CIDR="192.168.100.0/16"

# --------------------------------------------------
# Descargar las imágenes de Control Plane
# --------------------------------------------------
sudo kubeadm config images pull --cri-socket unix:///var/run/crio/crio.sock

echo "Descargar las imágenes de Control Plane"

#sudo kubeadm init --apiserver-advertise-address=$MASTER_IP --apiserver-cert-extra-sans=$MASTER_IP --pod-network-cidr=$POD_CIDR --node-name "$NODENAME" --ignore-preflight-errors Swap
sudo kubeadm init --apiserver-advertise-address=$MASTER_IP --apiserver-cert-extra-sans=$MASTER_IP --pod-network-cidr=$POD_CIDR --node-name "$NODENAME" --ignore-preflight-errors Swap --cri-socket unix:///var/run/crio/crio.sock

export KUBEADM_TOKEN=$(kubeadm token list | tail -n1 | cut -d" " -f1)
export KUBEADM_TOKEN_SHA=sha256:$(openssl x509 -in /etc/kubernetes/pki/ca.crt -noout -pubkey | openssl rsa -pubin -outform DER 2>/dev/null | sha256sum | cut -d' ' -f1)

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config <<<y
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Save Configs to shared /Vagrant location

# For Vagrant re-runs, check if there is existing configs in the location and delete it for saving new configuration.

CONFIG_PATH="$HOME/download/crio-configs"

if [ -d $CONFIG_PATH ]; then
  rm -rf $CONFIG_PATH
fi
mkdir -p $CONFIG_PATH

sudo cp -i /etc/kubernetes/admin.conf $CONFIG_PATH/config
sudo chown $(id -u):$(id -g) $CONFIG_PATH/config
touch $CONFIG_PATH/join-command.sh
chmod +x $CONFIG_PATH/join-command.sh

#sudo kubeadm token create --print-join-command | sudo tee $config_path/join.sh

export KUBEADM_TOKEN=$(kubeadm token list | tail -n1 | cut -d" " -f1)
export KUBEADM_TOKEN_SHA=sha256:$(openssl x509 -in /etc/kubernetes/pki/ca.crt -noout -pubkey | openssl rsa -pubin -outform DER 2>/dev/null | sha256sum | cut -d' ' -f1)

echo "kubeadm join ${MASTER_IP}:6443 --token ${KUBEADM_TOKEN} --discovery-token-ca-cert-hash ${KUBEADM_TOKEN_SHA} --cri-socket unix:///var/run/crio/crio.sock" > $CONFIG_PATH/join-command.sh

# Install Calico Network Plugin

#curl https://docs.projectcalico.org/manifests/calico.yaml -O
#kubectl apply -f calico.yaml

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml

# Install Metrics Server

kubectl apply -f https://raw.githubusercontent.com/scriptcamp/kubeadm-scripts/main/manifests/metrics-server.yaml

# Install Kubernetes Dashboard

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.1/aio/deploy/recommended.yaml

# Create Dashboard User

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

#kubectl -n kubernetes-dashboard get secret "$(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}")" -o go-template="{{.data.token | base64decode}}" >> /vagrant/configs/token

#sudo -i -u vagrant bash << EOF
#whoami
#mkdir -p /home/vagrant/.kube
#sudo cp -i /vagrant/configs/config /home/vagrant/.kube/
#sudo chown 1000:1000 /home/vagrant/.kube/config
#EOF

mkdir -p ${HOME}/.kube
sudo cp -i $CONFIG_PATH/config $HOME/.kube/ <<<y
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo chmod 664 $HOME/.kube/config

kubectl label node $(hostname -s) node-role.kubernetes.io/master=master

