#!/bin/bash

source ../clusters.sh

echo "================="
echo "DELETING CLUSTERS"
echo "================="

# Loop through each cluster context
for cluster in "${clusters[@]}"; do
    kind delete cluster --name "$cluster"
done