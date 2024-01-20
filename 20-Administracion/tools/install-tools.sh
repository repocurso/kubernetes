#!/bin/bash

# =========================================
# Herramientas relacionadas
# Instalación: podman skopeo buildah
# =========================================

source /etc/os-release
sudo bash -c "echo 'deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"
sudo curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key | sudo apt-key add -
sudo apt update
sudo apt install -y podman skopeo buildah

# Modificar los archivos de configuración
sudo sed -i 's/^\[machine\]$/#\[machine\]/' /usr/share/containers/containers.conf
sudo sed -i 's/mountopt = "nodev,metacopy=on"/mountopt = "dev,metacopy=on"/' /etc/containers/storage.conf

# Verificar las versiones de las herramientas
podman --version
skopeo --version
buildah --version
