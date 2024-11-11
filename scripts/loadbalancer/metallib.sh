# Define an array of cluster contexts
clusters=("kind-cluster1" "kind-cluster2")

# Obter o Cluster CIDR
CLUSTER_CIDR=$(docker network inspect kind | jq -r '.[0].IPAM.Config[] | select(.Subnet | test("^[0-9]")) | .Subnet')

# Extrair o prefixo (ex: 172.19.0) e definir o range de IPs
IP_PREFIX=$(echo $CLUSTER_CIDR | awk -F'[./]' '{print $1"."$2"."$3}')
IP_RANGE_START="${IP_PREFIX}.100"
IP_RANGE_END="${IP_PREFIX}.150"

# Construir o range de IPs para o MetalLB
METALLB_IP_RANGE="${IP_RANGE_START}-${IP_RANGE_END}"

# Loop through each cluster context
for cluster in "${clusters[@]}"; do
    echo "INSTALLING METALLIB FOR $cluster"
    kubectl cluster-info --context "$cluster"
    
    if [[ ! -z $METALLB_IP_RANGE ]]; then
    
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml
    # kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
    # kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml
    kubectl apply -f - <<EOF
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
kind: L2Advertisement
metadata:
  namespace: metallb-system
  name: my-l2-advertisement
spec: {}
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  namespace: metallb-system
  name: my-ip-pool
spec:
  addresses:
    - $METALLB_IP_RANGE 
EOF
    kubectl wait --for=condition=ready --timeout=5m pod -l app=metallb -n metallb-system

    echo "Show de metallb configmal"
    kubectl describe configmap config -n metallb-system    
fi

    
done

echo "INSTALLATION COMPLETE"

