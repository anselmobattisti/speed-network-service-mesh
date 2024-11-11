#!/bin/bash
echo "========"
echo "TEST DNS"
echo "========"

# Define an array of cluster contexts
source ../clusters.sh

# Loop through each cluster context
for cluster in "${clusters_context[@]}"; do    
    kubectl config use-context "$cluster"
    echo "==================="
    echo "Current K8s Cluster"
    echo "==================="
    kubectl config current-context

    kubectl run -it --rm dns-test --image=busybox:1.28 --restart=Never -- nslookup my.cluster1


    # kubectl delete deployment nginx
    # kubectl delete service nginx

    # kubectl create deployment nginx --image=nginx
    # kubectl expose deployment nginx --type=LoadBalancer --port=80

    # kubectl get svc
done