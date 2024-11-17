#!/bin/bash
#!/bin/bash
echo "========================="
echo "CONFIGURING LOAD BALANCER"
echo "========================="

source ../functions.sh

cluster_definition_load

# Loop through each cluster context
for cluster in "${clusters_context[@]}"; do    
    kubectl config use-context "$cluster"
    echo "==================="
    echo "Current K8s Cluster"
    echo "==================="
    kubectl config current-context

    if kubectl  --context "$cluster_context" get deployment nginx > /dev/null 2>&1; then
        echo "Service NGINX found. Deleting..."
        kubectl delete deployment nginx
        kubectl  --context "$cluster_context" delete service nginx
        echo "Service NGINX deleted successfully."        
    fi
done