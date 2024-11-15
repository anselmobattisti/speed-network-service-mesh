#!/bin/bash
#!/bin/bash
echo "==========================="
echo "DELETE ALPINE FROM CLUSTERS"
echo "==========================="

# Define an array of cluster contexts
source ../clusters.sh

# Function to get the logs of a pod from a partial name
delete_pods() {
    if [ -z "$1" ]; then
        echo "Usage: delete_pods <partial-pod-name> [context]"
        return 1
    fi

    # Use the provided context or default to the current context
    CONTEXT=${2:-$(kubectl config current-context)}

    # Get the full pod names using kubectl and filter by partial name
    POD_NAMES=$(kubectl --context="$CONTEXT" get pods | grep "$1" | awk '{print $1}')

    # Check if any pods were found
    if [ -z "$POD_NAMES" ]; then
        echo "No pods found matching: $1"
        return 1
    fi

    # Iterate through each pod and show logs
    while read -r pod; do
        if [ -n "$pod" ]; then
            echo "Pod ${pod} found. Deleting..."
            kubectl delete pod $pod  --context="$CONTEXT" 
            echo "Pod ${pod} deleted successfully."
            sleep 10            
        fi
    done <<< "$POD_NAMES"
}

POD_NAME="debug"

# Loop through each cluster context
for cluster_context in "${clusters_context[@]}"; do        
    delete_pods $POD_NAME $cluster_context
done