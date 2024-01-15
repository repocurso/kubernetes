#!/bin/bash

# Herramientas relacionadas
# Instalación: podman skopeo buildah

source /etc/os-release
sudo bash -c "echo 'deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"
sudo curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key | sudo apt-key add -
sudo apt update
sudo apt install -y podman skopeo buildah

sudo sed -i 's/^\[machine\]$/#\[machine\]/' /usr/share/containers/containers.conf

podman --version
skopeo --version
buildah --version
