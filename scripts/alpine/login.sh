#!/bin/bash

# Function to login to a pod by partial name
klogin() {
    if [ -z "$1" ]; then
        echo "Usage: klogin <partial-pod-name>"
        return 1
    fi

    # Get the full pod name using kubectl, grep, and awk
    POD_NAME=$(kubectl --context=$2 get pods | grep "$1" | awk '{print $1}')

    if [ -z "$POD_NAME" ]; then
        echo "No pod found matching: $1"
        return 1
    fi

    echo "Logging into pod: $POD_NAME"
    kubectl exec -it "$POD_NAME" --context=$2 -- /bin/sh
}

context=kind-cluster$1
echo "Context : $context"
klogin "debug" $context
