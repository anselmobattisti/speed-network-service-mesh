#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../clusters.sh"  # Load cluster names

source "$SCRIPT_DIR/delete.sh"

# Increase inotify limits
sudo sysctl fs.inotify.max_user_watches=524288000
sudo sysctl fs.inotify.max_user_instances=512000

echo "================="
echo "CREATING CLUSTERS IN PARALLEL"
echo "================="

# Function to create a cluster
create_cluster() {
    local cluster="$1"

    echo "[+] Creating cluster $cluster..."
    kind create cluster --name "$cluster" --image=kindest/node:v1.34.0 --config="${SCRIPT_DIR}/kind.yaml" &> "/tmp/kind_$cluster.log"

    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to create cluster $cluster. Check logs: /tmp/kind_$cluster.log"
        return 1
    fi

    # Wait for cluster to be ready
    while ! kubectl --context kind-"$cluster" get nodes >/dev/null 2>&1; do
        echo "[*] Waiting for cluster $cluster to be ready..."
        sleep 5
    done

    echo "+================================+"
    echo "| Cluster $cluster is ready :)   |"
    echo "+================================+"
}

# Loop through clusters and create them in parallel
for cluster in "${clusters[@]}"; do
    create_cluster "$cluster" &
done

# Wait for all background processes to finish
wait

echo "All clusters are created!"