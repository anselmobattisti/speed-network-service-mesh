#!/bin/bash

# Define an array of cluster contexts
clusters=("kind-cluster1" "kind-cluster2")

# Loop through each cluster context
for cluster in "${clusters[@]}"; do
    echo "DELETING DNS FOR $cluster"
    kubectl cluster-info --context "$cluster"    
    kubectl delete service -n kube-system exposed-kube-dns    
done

echo "DNS DELETED COMPLETE"
