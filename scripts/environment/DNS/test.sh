#!/bin/bash
echo "========"
echo "TEST DNS"
echo "========"

# Define an array of cluster contexts
source ../../clusters.sh

# Define variables
DEPLOYMENT_NAME="nginxtest"
SERVICE_NAME="nginxtest"
IP_STORAGE=()

# Clean up any existing deployment or service
kubectl --context=kind-cluster1 delete deployment $DEPLOYMENT_NAME --ignore-not-found=true
kubectl --context=kind-cluster1 delete service $SERVICE_NAME --ignore-not-found=true

# Create the deployment and expose it
kubectl --context=kind-cluster1 create deployment $DEPLOYMENT_NAME --image=nginx
kubectl --context=kind-cluster1 expose deployment $DEPLOYMENT_NAME --type=LoadBalancer --port=80

# Loop through each cluster context
for cluster in "${clusters_context[@]}"; do    
    echo "=============================="
    echo "Current K8s Cluster ${cluster}"
    echo "=============================="

    # Run nslookup and capture the output
    IP=$(kubectl --context=$cluster run -it --rm dns-test --image=busybox:1.28 --restart=Never -- /bin/sh -c "nslookup nginxtest.default.my.cluster1 | grep Address | tail -n 1 | awk '{print \$3}'")
    
    # Store the IP for comparison
    IP_STORAGE+=("$IP")

    echo "Cluster: $cluster, IP: $IP"
done

# Compare IPs
ALL_MATCH=true
BASE_IP="${IP_STORAGE[0]}"

for ip in "${IP_STORAGE[@]}"; do
    if [ "$ip" != "$BASE_IP" ]; then
        ALL_MATCH=false
        break
    fi
done

# Display comparison results
if [ "$ALL_MATCH" = true ]; then
    GREEN='\033[0;32m'
    NC='\033[0m' # No Color
    echo -e "${GREEN}All clusters resolved to the same IP: $BASE_IP${NC}"
else
    echo "Mismatch in resolved IPs across clusters:"
    for i in "${!clusters_context[@]}"; do
        echo "Cluster: ${clusters_context[$i]}, IP: ${IP_STORAGE[$i]}"
    done
fi

# Clean up resources
kubectl --context=kind-cluster1 delete deployment $DEPLOYMENT_NAME --ignore-not-found=true
kubectl --context=kind-cluster1 delete service $SERVICE_NAME --ignore-not-found=true