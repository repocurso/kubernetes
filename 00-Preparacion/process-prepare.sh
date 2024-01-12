#!/bin/bash

# Proceso en el nodo master actual
mkdir -p ~/download/prepare
cp ./prepare.* ~/download/prepare
cd ~/download/prepare
chmod u+x prepare.sh
./prepare.sh

# Proceso en los nodos workers
NODES="node1 node2"
for NODO in $NODES; do
  ssh $NODO mkdir -p ~/download/prepare 
  scp ~/download/prepare/* $NODO:~/download/prepare
  ssh $NODO "cd ~/download/prepare && bash -x ./prepare.sh"
  ssh $NODO rm -rf ~/download/prepare
done
rm -rf ~/download/prepare

