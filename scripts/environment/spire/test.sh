#!/bin/bash

source ../../clusters.sh

echo "======================="
echo " Test SPIRE Federation"
echo "======================="


# Apply DNS configuration for each cluster
for i in "${!clusters[@]}"; do
  
    cluster="${clusters[$i]}"
    current_context="${clusters_context[$i]}"
    current_ip="${clusters_ip[$i]}"

    echo "Cluster ${cluster}"

    kubectl exec spire-server-0 -n spire -c spire-server --context=$current_context -- bin/spire-server healthcheck
    echo "----"
done


