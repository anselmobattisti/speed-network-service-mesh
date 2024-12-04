#!/bin/bash

source ../functions.sh

printc "=======================" "orange"
printc " Test SPIRE Federation" "orange"
printc "=======================" "orange"

cluster_definition_load


# Apply DNS configuration for each cluster
for i in "${!clusters[@]}"; do
  
    cluster="${clusters[$i]}"
    current_context="${clusters_context[$i]}"
    current_ip="${clusters_ip[$i]}"

    printc "Cluster ${cluster}" "yellow"

    kubectl exec spire-server-0 -n spire -c spire-server --context=$current_context -- bin/spire-server healthcheck
    echo "----"
done


