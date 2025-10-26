#!/bin/bash

# ref: https://github.com/networkservicemesh/deployments-k8s/tree/57c860a607f3268fefa556341183c66a369dbcd7/examples/interdomain/three_cluster_configuration/basic

# In this point, all the required software (loadbalnce, DNS and spire) 
# are already installed in the clusters

echo "============================="
echo " INSTALL NSM IN THE CLUSTERS "
echo "============================="

# Enable error handling
set -e

source ../clusters.sh

get_federated_with_domain() {
    # Check if the required argument is provided
    if [ -z "$1" ]; then
        echo "Usage: get_federated_with_domain <new_cluster_name>"
        return 1
    fi

    local NEW_CLUSTER="$1"
    local federated_with=()

    for current_cluster in "${clusters[@]}"; do
        if [[ "$current_cluster" != "$NEW_CLUSTER" ]]; then
            federated_with+=("nsm.$current_cluster")
        fi
    done

    # Join the array into a comma-separated string
    local IFS=',' # Set the internal field separator to a comma
    echo "${federated_with[*]}"
}

update_patch_file() {
    local template="$1"
    local output="$2"
    local placeholder="$3"
    local value="$4"

    echo "Start Updating file ${template} to ${output}"
    mkdir -p "$(dirname "$output")"
    sed -e "s|$placeholder|$value|" "$template" > "$output"
    echo "Finish Updating file ${template} to ${output}"
}

copy_common_files() {
    local NEW_CLUSTER="$1"
    local OUTPUT_DIR="clusters/${NEW_CLUSTER}"
    local files_to_copy=("kustomization.yaml" "nsm-system-namespace.yaml" "patch-registry-service.yaml")

    mkdir -p "$OUTPUT_DIR"

    for file_name in "${files_to_copy[@]}"; do
        local INPUT_FILE="files/cluster-worker/${file_name}"
        local OUTPUT_FILE="${OUTPUT_DIR}/${file_name}"
        echo "Copying ${INPUT_FILE} to ${OUTPUT_FILE}"
        cp "$INPUT_FILE" "$OUTPUT_FILE"
    done
}

create_files_workers() {
    local NEW_CLUSTER="$1"

    mkdir -p ./clusters/"${NEW_CLUSTER}"

    update_patch_file \
        "files/cluster-worker/cluster-property.yaml" \
        "clusters/${NEW_CLUSTER}/cluster-property.yaml" \
        "{cluster_name}" \
        "$NEW_CLUSTER"

    local federated_with=$(get_federated_with_domain "$NEW_CLUSTER")

    update_patch_file \
        "files/cluster-worker/patch-nsmgr-proxy.yaml" \
        "clusters/${NEW_CLUSTER}/patch-nsmgr-proxy.yaml" \
        "{federated_with}" \
        "$federated_with"

    update_patch_file \
        "files/cluster-worker/patch-registry-memory.yaml" \
        "clusters/${NEW_CLUSTER}/patch-registry-memory.yaml" \
        "{federated_with}" \
        "$federated_with"

    update_patch_file \
        "files/cluster-worker/patch-registry-proxy-dns.yaml" \
        "clusters/${NEW_CLUSTER}/patch-registry-proxy-dns.yaml" \
        "{federated_with}" \
        "$federated_with"

    copy_common_files "$NEW_CLUSTER"
}

create_files_registry(){
    local NEW_CLUSTER="$1"

    mkdir -p ./clusters/"${NEW_CLUSTER}"

    local federated_with=$(get_federated_with_domain "$NEW_CLUSTER")

    update_patch_file \
    "files/cluster-registry/patch-registry-k8s.yaml" \
    "clusters/${NEW_CLUSTER}/patch-registry-k8s.yaml" \
    "{federated_with}" \
    "$federated_with"
    
    update_patch_file \
    "files/cluster-registry/patch-vl3-ipam.yaml" \
    "clusters/${NEW_CLUSTER}/patch-vl3-ipam.yaml" \
    "{federated_with}" \
    "$federated_with"

    local OUTPUT_DIR="clusters/${NEW_CLUSTER}"
    local files_to_copy=("kustomization.yaml" "nsm-system-namespace.yaml" "patch-registry-service.yaml" "patch-ipam-service.yaml")

    mkdir -p "$OUTPUT_DIR"

    for file_name in "${files_to_copy[@]}"; do
        local INPUT_FILE="files/cluster-registry/${file_name}"
        local OUTPUT_FILE="${OUTPUT_DIR}/${file_name}"
        echo "Copying ${INPUT_FILE} to ${OUTPUT_FILE}"
        cp "$INPUT_FILE" "$OUTPUT_FILE"
    done    
}

base_files() {
    echo "Removing previously configured folder"
    rm -Rf ./clusters
    mkdir ./clusters
    echo "Removed and re-created folder for clusters"
}

main() {
    base_files

    # Worker clusters
    for ((i = 0; i < ${#clusters[@]} - 1; i++)); do   
        local cluster="${clusters[$i]}"

        echo "====================================="
        echo " Configuring Worker Cluster ${cluster}"
        echo "====================================="

        create_files_workers "$cluster"
    done

    # Get the last value of the array
    last_index=$(( ${#clusters[@]} - 1 ))  # Calculate the index of the last element
    registry_cluster="${clusters[$last_index]}"  # Access the last element
    registry_cluster_context="${clusters_context[$last_index]}"

    echo "====================================="
    echo " Configuring Registry Cluster ${registry_cluster}"
    echo "====================================="

    create_files_registry $registry_cluster

    rm -Rf about-api
    git clone https://github.com/kubernetes-sigs/about-api.git
    
    echo "================="
    echo " Installing NSM "
    echo "================="

    # Install the NSM in the clusters
    for i in "${!clusters[@]}"; do    
        cluster="${clusters[$i]}"
        current_context="${clusters_context[$i]}"

        kubectl --context=$current_context apply -k about-api/clusterproperty/config/crd/

        kubectl --context=$current_context apply -k "./clusters/${cluster}"
    done

    rm -Rf about-api

    # Wait for the IP to be assigned
    NAMESPACE="nsm-system"
    SERVICE_NAME="registry"
    while true; do
        echo "Waiting for external IP for service $SERVICE_NAME in context $current_context..."

        IP=$(kubectl --context="$registry_cluster_context" get services "$SERVICE_NAME" -n "$NAMESPACE" \
            -o go-template='{{index (index (index (index .status "loadBalancer") "ingress") 0) "ip"}}')

        if [ -n "$IP" ]; then
            echo "Service $SERVICE_NAME external IP: $IP"
            break
        fi

        sleep 5 # Wait for 5 seconds before retrying
    done    
}

main "$@"