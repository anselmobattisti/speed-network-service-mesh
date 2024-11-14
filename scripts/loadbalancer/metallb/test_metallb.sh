#!/bin/bash
echo "================================="
echo "CHECKING LOAD BALANCER WITH NGINX"
echo "================================="

# Define an array of cluster contexts
source ../../clusters.sh

./delete_test.sh

# Loop through each cluster context
for cluster in "${clusters_context[@]}"; do    
    kubectl config use-context "$cluster"
    echo "==================="
    echo "Current K8s Cluster"
    echo "==================="
    kubectl config current-context

    kubectl create deployment nginx --image=nginx
    kubectl expose deployment nginx --type=LoadBalancer --port=80

    kubectl get svc
done


