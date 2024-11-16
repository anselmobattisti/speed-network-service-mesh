#!/bin/bash

echo "================"
echo " DELETING SPIRE "
echo "================"

if [[ ! -f ../clusters.sh ]]; then
    echo "Error: clusters.sh not found!"
    exit 1
fi

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

    echo "DELETING SPIRE FOR $cluster"

    check_and_delete "crd" "clusterspiffeids.spire.spiffe.io" $current_context
    check_and_delete "crd" "clusterfederatedtrustdomains.spire.spiffe.io" $current_context
    check_and_delete "validatingwebhookconfiguration.admissionregistration.k8s.io" "spire-controller-manager-webhook" $current_context
    check_and_delete "namespace" "spire" $current_context
done

echo "DELETION COMPLETE"