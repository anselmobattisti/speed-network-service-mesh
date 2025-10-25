#!/bin/bash
echo "================================="
echo "CHECKING LOAD BALANCER WITH NGINX"
echo "================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../clusters.sh"  # Correct reference to another file in the same folder

source "${SCRIPT_DIR}/delete_test.sh"

# Loop through each cluster context
for cluster in "${clusters_context[@]}"; do    
    kubectl config use-context "$cluster"
    echo "==================="
    echo "Current K8s Cluster"
    echo "==================="
    kubectl config current-context

    kubectl create deployment nginx --image=nginx
    kubectl expose deployment nginx --type=LoadBalancer --port=80

    kubectl get svc nginx
done


