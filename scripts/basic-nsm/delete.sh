#!/bin/bash

echo "===================="
echo " DELETING BASIC NSM "
echo "===================="

source ../clusters.sh

# Function to check if a resource exists
check_and_delete() {
    resource_type=$1
    resource_name=$2
    context=$3

    if kubectl get $resource_type $resource_name --context=$context >/dev/null 2>&1; then
        echo "Deleting $resource_type $resource_name in context $context"
        kubectl delete $resource_type $resource_name --context=$context
    else
        echo "$resource_type $resource_name not found in context $context, skipping."
    fi
}

# Apply DNS configuration for each cluster
for i in "${!clusters[@]}"; do
    cluster="${clusters[$i]}"
    current_context="${clusters_context[$i]}"

    echo "DELETING NSM BASIC FOR $cluster"

    check_and_delete "mutatingwebhookconfiguration" "nsm-mutating-webhook" $current_context
    check_and_delete "namespace" "nsm-system" $current_context

done

echo "DELETION COMPLETE"