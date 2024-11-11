#!/bin/bash

# Define an array of cluster contexts
clusters=("kind-cluster1" "kind-cluster2")

# Loop through each cluster context
for cluster in "${clusters[@]}"; do
    echo "INSTALLING SPIRE FOR $cluster"
    kubectl cluster-info --context "$cluster"
    kubectl apply -k https://github.com/networkservicemesh/deployments-k8s/examples/spire/single_cluster?ref=v1.14.0
    
    echo "WAITING TO THE spire-server BECAME READY"
    kubectl wait -n spire --timeout=4m --for=condition=ready pod -l app=spire-server
    
    echo "WAITING TO THE spire-agent BECAME READY"
    kubectl wait -n spire --timeout=1m --for=condition=ready pod -l app=spire-agent

    echo "INSTALLING THE CRDs"
    kubectl apply -f https://raw.githubusercontent.com/networkservicemesh/deployments-k8s/v1.14.0/examples/spire/single_cluster/clusterspiffeid-template.yaml
    kubectl apply -f https://raw.githubusercontent.com/networkservicemesh/deployments-k8s/v1.14.0/examples/spire/base/clusterspiffeid-webhook-template.yaml

    echo "SLEEPING 10s"
    sleep 10
done

echo "INSTALLATION COMPLETE"

# #!/bin/bash
# echo "INSTALLING SPIRE CLUSTER 1"
# kubectl cluster-info --context kind-cluster1
# kubectl apply -k https://github.com/networkservicemesh/deployments-k8s/examples/spire/single_cluster?ref=v1.14.0

# echo "SLEEPING 10s"
# sleep 10

# echo "INSTALLING SPIRE CLUSTER 2"
# kubectl cluster-info --context kind-cluster2
# kubectl apply -k https://github.com/networkservicemesh/deployments-k8s/examples/spire/single_cluster?ref=v1.14.0
