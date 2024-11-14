#!/bin/bash
#!/bin/bash
echo "==========================="
echo "DELETE ALPINE FROM CLUSTERS"
echo "==========================="

# Define an array of cluster contexts
source ../clusters.sh

POD_NAME="alpine"

# Loop through each cluster context
for cluster in "${clusters_context[@]}"; do    
    kubectl config use-context "$cluster"
    echo "==================="
    echo "Current K8s Cluster"
    echo "==================="
    kubectl config current-context

    if kubectl  --context "$cluster_context" get pod ${POD_NAME} > /dev/null 2>&1; then
        echo "Pod ${POD_NAME} found. Deleting..."
        kubectl delete pod $POD_NAME        
        echo "Pod ${POD_NAME} deleted successfully."
        sleep 10
    fi
done