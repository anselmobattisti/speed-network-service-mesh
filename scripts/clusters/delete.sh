#!/bin/bash

source ../functions.sh

cluster_definition_load

echo "================="
echo "DELETING CLUSTERS"
echo "================="

# Loop through each cluster context
for cluster in "${clusters[@]}"; do
    kind delete cluster --name "$cluster"
done