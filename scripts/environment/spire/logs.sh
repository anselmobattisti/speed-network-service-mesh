#!/bin/bash

# ref: https://github.com/networkservicemesh/deployments-k8s/tree/main/examples/spire

echo "============"
echo " LOGS SPIRE "
echo "============"

source ../functions.sh

cluster_definition_load

# Show spire logs in all the clusters
for i in "${!clusters[@]}"; do
  
  cluster="${clusters[$i]}"
  current_context="${clusters_context[$i]}"
  current_ip="${clusters_ip[$i]}"

  echo "=================================="
  echo " Cluster ${cluster}"
  echo "=================================="
  
  kubectl logs spire-server-0 -n spire --context=$current_context
done