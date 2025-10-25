#!/bin/bash
echo "========================="
echo "CONFIGURING LOAD BALANCER"
echo "========================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../clusters.sh"  # Correct reference to another file

# Function to check if the controller pod is ready
is_controller_ready() {
    kubectl get pods -n metallb-system -l "component=controller" -o jsonpath='{.items[0].status.containerStatuses[0].ready}' 2>/dev/null
}

# Get the Cluster CIDR
CLUSTER_CIDR=$(docker network inspect kind | jq -r '.[0].IPAM.Config[] | select(.Subnet | test("^[0-9]")) | .Subnet')

# Extract the base prefix (e.g., 172.19)
IP_BASE=$(echo $CLUSTER_CIDR | awk -F'[./]' '{print $1"."$2}')

# Set initial subnet counter (starts from 1 → 172.19.1.x)
subnet_counter=1

# Loop through each cluster context
for cluster in "${clusters_context[@]}"; do
    kubectl config use-context "$cluster"
    echo "==================="
    echo "Current K8s Cluster"
    echo "==================="
    kubectl config current-context

    # Define IP range for the current cluster (e.g., 172.19.1.1 - 172.19.1.255)
    IP_RANGE_START="${IP_BASE}.${subnet_counter}.1"
    IP_RANGE_END="${IP_BASE}.${subnet_counter}.255"

    # Construct MetalLB IP range
    METALLB_IP_RANGE="${IP_RANGE_START}-${IP_RANGE_END}"

    if [[ ! -z $METALLB_IP_RANGE ]]; then

    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml

    echo "Waiting for the MetalLB controller pod to become Ready..."

    while true; do
        READY=$(is_controller_ready)
        if [[ "$READY" == "true" ]]; then
            echo "The MetalLB controller pod is Ready."
            break
        else
            echo "The MetalLB controller pod is not Ready yet. Retrying in 5 seconds..."
            sleep 5
        fi
    done

cat <<EOF > metallb-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - $METALLB_IP_RANGE
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  namespace: metallb-system
  name: my-ip-pool
spec:
  addresses:
    - $METALLB_IP_RANGE
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  namespace: metallb-system
  name: my-l2-advertisement
spec: {}
EOF

kubectl apply -f metallb-config.yaml
rm metallb-config.yaml  # Clean up the temp file

    kubectl wait --for=condition=ready --timeout=5m pod -l app=metallb -n metallb-system

    echo "Show de metallb configmap"
    kubectl config current-context
    kubectl cluster-info
    kubectl describe configmap config -n metallb-system

    # Increment subnet counter for the next cluster
    ((subnet_counter++))
fi

done

echo "INSTALLATION COMPLETE"