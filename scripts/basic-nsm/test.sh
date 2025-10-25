#!/bin/bash
# Test if the components are running correctly

echo "==========================="
echo " Test if the Workers Nodes "
echo "==========================="

# Enable error handling
set -e

source ../clusters.sh

NAMESPACE="nsm-system"

main() {
    # Worker clusters
    for ((i = 0; i < ${#clusters[@]} - 1; i++)); do   
   
        cluster="${clusters[$i]}"
        current_context="${clusters_context[$i]}"    
    
        echo "====================================="
        echo " Test Process nsmgr-proxy in ${cluster}"
        echo "====================================="

        # Define the Kubernetes context and the namespace        
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

    # List ALL pods
    for ((i = 0; i < ${#clusters[@]}; i++)); do   
   
        cluster="${clusters[$i]}"
        current_context="${clusters_context[$i]}"    
    
        echo "========================================================================="
        echo " List all pods in the cluster ${cluster}" namespace ${NAMESPACE="nsm-system"}
        echo "========================================================================="

        # List all pods in the namespace
        pod_status=$(kubectl get pods -n $NAMESPACE --context=$current_context --no-headers)

        echo "$pod_status"

        # Check for pods that are not running
        if echo "$pod_status" | grep -v -E "Running|Completed" > /dev/null; then
            echo "ERROR: One or more pods are not in 'Running' or 'Completed' state in the cluster ${cluster} (namespace: $NAMESPACE)"
            echo "Details of problematic pods:"
            echo "$pod_status" | grep -v -E "Running|Completed"
        else
            echo "All pods are running or completed in the cluster ${cluster} (namespace: $NAMESPACE)"
        fi
    done
}

main "@"