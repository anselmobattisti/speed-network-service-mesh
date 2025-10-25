#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../clusters.sh"  # Correct reference to another file in the same folder

echo "================="
echo "DELETING CLUSTERS"
echo "================="

# Loop through each cluster context
for cluster in "${clusters[@]}"; do
    kind delete cluster --name "$cluster"
done