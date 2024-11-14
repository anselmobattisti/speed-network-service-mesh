#!/bin/bash

# Function to get the logs of a pod from a partial name
klogs() {
    if [ -z "$1" ]; then
        echo "Usage: klogs <partial-pod-name> [context]"
        return 1
    fi

    # Use the provided context or default to the current context
    CONTEXT=${2:-$(kubectl config current-context)}

    # Get the full pod names using kubectl and filter by partial name
    POD_NAMES=$(kubectl --context="$CONTEXT" get pods -n kube-system | grep "$1" | awk '{print $1}')

    # Check if any pods were found
    if [ -z "$POD_NAMES" ]; then
        echo "No pods found matching: $1"
        return 1
    fi

    # Iterate through each pod and show logs
    while read -r pod; do
        if [ -n "$pod" ]; then
            echo "===== Logs from pod: $pod ====="
            kubectl logs "$pod" --context="$CONTEXT" -n kube-system
            echo "================================"
        fi
    done <<< "$POD_NAMES"
}

context=kind-cluster$1
echo "Context : $context"
klogs "coredns" $context
