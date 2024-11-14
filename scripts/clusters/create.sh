#!/bin/bash
./delete.sh

sudo sysctl fs.inotify.max_user_watches=524288
sudo sysctl fs.inotify.max_user_instances=512

source ../clusters.sh

echo "================="
echo "CREATING CLUSTERS"
echo "================="

# Loop through each cluster context
for cluster in "${clusters[@]}"; do
    
    kind create cluster --name  "$cluster" --image=kindest/node:v1.31.1 --config=kind.yaml

    # Check for errors
    if [ $? -ne 0 ]; then
        echo "Error creating cluster $cluster"
        exit 1
    fi
    
    while ! kubectl --context kind-"$cluster" get nodes >/dev/null 2>&1; do
        echo "Waiting for cluster $cluster to be ready..."
        sleep 5
    done
    echo "+==============================+"
    echo "| Cluster $cluster is ready :) |"
    echo "+==============================+"

    # # Step 2: Configure CoreDNS with the custom domain
    # echo "Configuring CoreDNS for $cluster"

    # custom_domain="my.${cluster}"

    # kubectl --context="kind-${cluster}" get configmap coredns -n kube-system -o yaml | sed "s|cluster.local|${custom_domain}|g" | kubectl --context="kind-${cluster}" apply -f -

    # # Restart CoreDNS to apply changes
    # kubectl --context="kind-${cluster}" rollout restart deployment coredns -n kube-system

    # echo "CoreDNS configured for custom domain: ${custom_domain}"    
done