#!/bin/bash

# ref: https://github.com/networkservicemesh/deployments-k8s/tree/v1.14.0/examples/interdomain/two_cluster_configuration/dns

echo "==============="
echo "CONFIGURING DNS"
echo "==============="

source ../clusters.sh

# Define arrays for clusters and their kubeconfig contexts
clusters_ip=()  # This will be populated dynamically

# Function to expose DNS and wait for LoadBalancer IP
get_dns_lb_ip() {
  local cluster_name=$1
  local cluster_context=$2

  echo "Exposing kube-dns service for $cluster_name ($cluster_context)..."

  # Service name and namespace
  SERVICE_NAME="exposed-kube-dns"
  NAMESPACE="kube-system"

  # Check if the service exists
  if kubectl  --context "$cluster_context" get service "$SERVICE_NAME" -n "$NAMESPACE" > /dev/null 2>&1; then
      echo "Service '$SERVICE_NAME' found in namespace '$NAMESPACE'. Deleting..."
      kubectl  --context "$cluster_context" delete service "$SERVICE_NAME" -n "$NAMESPACE"
      echo "Service '$SERVICE_NAME' deleted successfully."
  fi
    
  # Expose the kube-dns service as LoadBalancer
  kubectl --context "$cluster_context" expose service kube-dns -n kube-system \
      --port=53 --target-port=53 --protocol=TCP --name=exposed-kube-dns --type=LoadBalancer

  # Wait until LoadBalancer IP is assigned
  while true; do
    echo "Waiting for LoadBalancer IP assignment for $cluster_name..."

    LB_IP=$(kubectl get services exposed-kube-dns -n kube-system --context "$cluster_context" \
        -o go-template='{{index (index (index (index .status "loadBalancer") "ingress") 0) "ip"}}')

    # Check if LB_IP is not empty
    if [[ ! -z "$LB_IP" ]]; then
      echo "LoadBalancer IP assigned for $cluster_name: $LB_IP"
      clusters_ip+=("$LB_IP")
      break
    fi

    # Wait for 5 seconds before checking again
    sleep 5
  done

  # Allow a short delay before configuring the next cluster
  echo "Sleeping 10s to allow DNS propagation..."
  sleep 10
}

# Loop through each cluster to expose DNS and get LoadBalancer IP
for i in "${!clusters[@]}"; do  
  get_dns_lb_ip "${clusters[$i]}" "${clusters_context[$i]}"
done
echo "-----"
echo "All LoadBalancer IPs collected: ${clusters_ip[@]}"
echo "Configuration can proceed with the following IPs: ${clusters_ip[@]}"
echo "-----"

# Function to create CoreDNS configuration dynamically
generate_dns_config() {
  local current_cluster=$1
  local current_ip=$2

  stubDomains=""
  # Loop to add inter-cluster DNS forwarding for other clusters
  for i in "${!clusters[@]}"; do
    if [[ "${clusters[$i]}" != "$current_cluster" ]]; then
      stubDomains+="stub 
            ${clusters[$i]}.local [${clusters_ip[$i]}]
        "
    fi
  done
  stubDomains+="}"

  local config="apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        log
        health {
            lameduck 5s
        }
        ready
        kubernetes ${current_cluster}.local in-addr.arpa ip6.arpa {
            pods insecure
            fallthrough in-addr.arpa ip6.arpa
            ttl 30
        }
        ${stubDomains}        
        prometheus :9153
        forward . /etc/resolv.conf {
            max_concurrent 1000
        }
        loop
        reload 5s
    }"


  # # Loop to add inter-cluster DNS forwarding for other clusters
  # for i in "${!clusters[@]}"; do
  #   if [[ "${clusters[$i]}" != "$current_cluster" ]]; then
  #     config+="
  #   ${clusters[$i]}.local:53 {
  #     log
  #     forward . ${clusters_ip[$i]} {
  #       force_tcp
  #     }
  #   }"
  #   fi
  # done

#   config+="
# ---
# apiVersion: v1
# kind: ConfigMap
# metadata:
#   name: coredns-custom
#   namespace: kube-system
# data:
#   server.override: |
#     k8s_external "$current_cluster".local"

#   # Loop to add inter-cluster DNS forwarding for other clusters
#   for i in "${!clusters[@]}"; do
#     if [[ "${clusters[$i]}" != "$current_cluster" ]]; then
#       proxy_id=$((i+1))
#       config+="  
#   proxy"$proxy_id".server: |    
#     ${clusters[$i]}.local:53 {
#       forward . ${clusters_ip[$i]} {
#         force_tcp
#       }
#     }"
#     fi
#   done

  echo "$config"
}

# Apply DNS configuration for each cluster
for i in "${!clusters[@]}"; do
  
  current_cluster="${clusters[$i]}"
  current_context="${clusters_context[$i]}"
  current_ip="${clusters_ip[$i]}"

  echo "Configuring DNS for $current_cluster with context $current_context..."

  # Generate dynamic DNS configuration
  dns_config=$(generate_dns_config "$current_cluster" "$current_ip")

    printf "%s\n" "$dns_config"
#   exit

  # Apply the generated ConfigMap to the current cluster context
  echo "$dns_config" | kubectl --context "$current_context" apply -f -

  # Restart CoreDNS to apply the new configuration
  kubectl rollout restart deployment coredns -n kube-system --context "$current_context"
  
  echo "DNS configuration applied for $current_cluster."
done

echo "DNS configuration completed for all clusters."