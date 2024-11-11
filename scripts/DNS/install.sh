#!/bin/bash

# Define an array of cluster contexts
clusters=("kind-cluster1" "kind-cluster2")

# Loop through each cluster context
for cluster in "${clusters[@]}"; do
    echo "CONFIGURING DNS FOR $cluster"
    kubectl cluster-info --context "$cluster"
    
    kubectl expose service kube-dns -n kube-system --port=53 --target-port=53 --protocol=TCP --name=exposed-kube-dns --type=LoadBalancer

    # Loop until the LoadBalancer IP is assigned (not empty)
    while true; do
        echo "Waiting for LoadBalancer IP assignment..."

        LB_IP=$(kubectl get services exposed-kube-dns -n kube-system -o go-template='{{index (index (index (index .status "loadBalancer") "ingress") 0) "ip"}}')
        
        # Check if LB_IP is not empty
        if [[ ! -z "$LB_IP" ]]; then
            echo "LoadBalancer IP assigned: $LB_IP"
            break
        fi

        # Wait for 5 seconds before checking again
        sleep 5
    done

    echo "SLEEPING 10s"
    sleep 10
done

echo "DNS INSTALLATION COMPLETE"