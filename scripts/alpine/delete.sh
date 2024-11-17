#!/bin/bash
#!/bin/bash
echo "==========================="
echo "DELETE ALPINE FROM CLUSTERS"
echo "==========================="

source ../functions.sh

cluster_definition_load

# Loop through each cluster context
for cluster_context in "${clusters_context[@]}"; do        
    kubectl delete -f alpine.yaml --context $cluster_context
done