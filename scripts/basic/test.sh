#!/bin/bash
# Test if the components are running correctly

echo "==========================="
echo " Test if the Workers Nodes "
echo "==========================="

# Enable error handling
set -e

source ../functions.sh

cluster_definition_load

main() {
    # Worker clusters
    # Worker clusters
    for ((i = 0; i < ${#clusters[@]} - 1; i++)); do   
   
        cluster="${clusters[$i]}"
        current_context="${clusters_context[$i]}"    
    
        echo "====================================="
        echo " Test Process nsmgr-proxy in ${cluster}"
        echo "====================================="

        # Define the Kubernetes context and the namespace
        NAMESPACE="nsm-system"
        SERVICE_NAME="nsmgr-proxy"

        # Wait for the IP to be assigned
        while true; do
            echo "Waiting for external IP for service $SERVICE_NAME in context $CONTEXT..."

            # Run the kubectl command and capture the IP
            IP=$(kubectl --context="$current_context" get services "$SERVICE_NAME" -n "$NAMESPACE" \
                -o go-template='{{index (index (index (index .status "loadBalancer") "ingress") 0) "ip"}}')

            # Check if the IP is non-empty
            if [ -n "$IP" ]; then
                echo "Service $SERVICE_NAME external IP: $IP"
                break
            fi

            # Wait for 5 seconds before retrying
            sleep 5
        done
    done
    
    # Get the last value of the array
    last_index=$(( ${#clusters[@]} - 1 ))  # Calculate the index of the last element
    registry_cluster="${clusters[$last_index]}"  # Access the last element
    registry_cluster_context="${clusters_context[$last_index]}"

    echo "========================================================"
    echo " Test Process nsmgr-proxy in ${registry_cluster} Registry Cluster"
    echo "========================================================="

    # Wait for the IP to be assigned
    NAMESPACE="nsm-system"
    SERVICE_NAME="registry"
    while true; do
        echo "Waiting for external IP for service $SERVICE_NAME in context $registry_cluster..."

        IP=$(kubectl --context="$registry_cluster_context" get services "$SERVICE_NAME" -n "$NAMESPACE" \
            -o go-template='{{index (index (index (index .status "loadBalancer") "ingress") 0) "ip"}}')

        if [ -n "$IP" ]; then
            echo "Service $SERVICE_NAME external IP: $IP"
            break
        fi

        sleep 5 # Wait for 5 seconds before retrying
    done
}

main "@"