#!/bin/bash
echo "=============================="
echo "CREATING ALPINE FROM CLUSTERS"
echo "=============================="

source ../functions.sh

cluster_definition_load

# Apply DNS configuration for each cluster
for i in "${!clusters[@]}"; do
  
    current_cluster="${clusters[$i]}"
    current_context="${clusters_context[$i]}"

    echo "--------------------"
    echo "Current K8s Cluster "
    echo "--------------------"    
    echo $current_context

    kubectl --context=$current_context apply -f alpine.yaml    
done