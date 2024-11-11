#!/bin/bash
./delete.sh
source ../clusters.sh

echo "================="
echo "CREATING CLUSTERS"
echo "================="

# Loop through each cluster context
for cluster in "${clusters[@]}"; do

    
    kind create cluster --name  "$cluster" --image=kindest/node:v1.31.2 --config=kind.yaml

    echo "SLEEPING FOR 10s"
    sleep 10
done