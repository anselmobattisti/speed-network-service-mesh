#!/bin/bash
echo "========================="
echo "CHECKING LOAD BALANCER"
echo "========================="

# Define an array of cluster contexts
source ../../clusters.sh

# Loop through each cluster context
for cluster in "${clusters_context[@]}"; do    
    kubectl config use-context "$cluster"
    echo "==================="
    echo "Current K8s Cluster"
    echo "==================="
    kubectl config current-context
    kubectl describe configmap config -n metallb-system
done