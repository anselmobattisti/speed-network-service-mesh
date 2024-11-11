#!/bin/bash

# Define an array of cluster contexts
clusters=("kind-cluster1" "kind-cluster2")

# Loop through each cluster context
for cluster in "${clusters[@]}"; do
    echo "DELETING SPIRE FOR $cluster"
    kubectl delete crd clusterspiffeids.spire.spiffe.io
    kubectl delete crd clusterfederatedtrustdomains.spire.spiffe.io
    kubectl delete validatingwebhookconfiguration.admissionregistration.k8s.io/spire-controller-manager-webhook
    kubectl delete ns spire
done

echo "DELETION COMPLETE"