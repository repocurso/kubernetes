#!/bin/bash

# Instlación y Configuración para todos los nodos (Control Plane y workers)

set -euxo pipefail

# iDeclaración de Variables
KUBERNETES_VERSION="1.25.5-00"
KUBERNETES_VERSION="1.28.2-00"
KUBERNETES_VERSION="$1"

# --------------------------------------------------
# Preparar el sistema operativo de los nodos
# --------------------------------------------------

# Desactivar swap
sudo swapoff -a
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true

# Crear el archivo de configuración (.conf) para cargar los módulos en el arranque
cat <<EOF | sudo tee /etc/modules-load.d/crio.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Configurar los parámetros sysctl requeridos, estos persisten a través de los reinicios
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

echo "** Preparar el sistema operativo de los nodos"

# --------------------------------------------------
# Actualizar el sistema e instalar las dependencias
# --------------------------------------------------
sudo apt-get -qq update
#sudo apt-get install -y apt-transport-https ca-certificates curl
sudo apt -qq install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common

echo "** ** Preparar el sistema operativo de los nodos"

# --------------------------------------------------
# Agregar el repositorio de CRI-O
# --------------------------------------------------
export OS="xUbuntu_20.04"
export CRIO_VERSION="1.26"

cat <<EOT | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /
EOT
cat <<EOT | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list
deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /
EOT

curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION/$OS/Release.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers.gpg add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers.gpg add -

echo "** Agregar el repositorio de CRI-O"

# --------------------------------------------------
# Instalar CRI-O Runtime
# --------------------------------------------------
sudo apt-get -qq update 
sudo apt-get -qq install -y cri-o cri-o-runc

sudo systemctl daemon-reload
sudo systemctl enable crio --now
sudo systemctl start crio --now

echo "Instalar CRI-O Runtime"

# --------------------------------------------------
# Instalar kubelet, kubectl y kubeadm
# --------------------------------------------------

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get -qq update
sudo apt-get -qq install -y kubelet="$KUBERNETES_VERSION" kubectl="$KUBERNETES_VERSION" kubeadm="$KUBERNETES_VERSION"
sudo apt-get -qq install -y jq

LOCAL_IP="$(ip --json a s | jq -r '.[] | if .ifname == "eth1" then .addr_info[] | if .family == "inet" then .local else empty end else empty end')"
sudo cat << EOT | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS=--node-ip=$LOCAL_IP
EOT

