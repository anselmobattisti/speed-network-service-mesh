#!/bin/bash

# ref: https://github.com/networkservicemesh/deployments-k8s/tree/main/examples/spire

echo "==================="
echo " CONFIGURING SPIRE "
echo "==================="

if [[ ! -f ../clusters.sh ]]; then
    echo "Error: clusters.sh not found!"
    exit 1
fi

# load the cluster names
source ../clusters.sh

bootstrap_spiffe_federation() {
    # Check if the required arrays are defined
    if [ ${#clusters[@]} -lt 2 ] || [ ${#clusters_context[@]} -lt 2 ]; then
        echo "Error: At least two clusters and contexts are required for federation."
        return 1
    fi

    echo "================================="
    echo " Bootstrapping SPIFFE Federation"
    echo "================================="

    # Step 1: Retrieve trust bundles for each cluster
    declare -A bundles
    for i in "${!clusters[@]}"; do
        cluster_name="${clusters[$i]}"
        current_context="${clusters_context[$i]}"

        echo "------------------------------------"
        echo "Fetching trust bundle for $cluster_name..."
        echo "------------------------------------"
        bundle=$(kubectl --context="$current_context" exec spire-server-0 -n spire -c spire-server -- bin/spire-server bundle show -format spiffe)

        if [ -z "$bundle" ]; then
            echo "Error: Failed to retrieve bundle for $cluster_name"
            return 1
        fi

        bundles[$cluster_name]="$bundle"
    done

    # Step 2: Set trust bundles for each cluster
    for i in "${!clusters[@]}"; do
        current_cluster="${clusters[$i]}"
        current_context="${clusters_context[$i]}"

        echo "Configuring federation for $current_cluster..."

        for j in "${!clusters[@]}"; do
            target_cluster="${clusters[$j]}"
            target_context="${clusters_context[$j]}"

            if [[ "$current_cluster" != "$target_cluster" ]]; then
                echo "Setting bundle for $target_cluster in $current_cluster..."
                echo "${bundles[$target_cluster]}" | \
                    kubectl --context="$current_context" exec -i spire-server-0 -n spire -c spire-server -- \
                    bin/spire-server bundle set -format spiffe -id "spiffe://${target_cluster}"
            fi
        done
    done

    kubectl rollout restart statefulset spire-server -n spire --context "$current_context"

    echo "==========================="
    echo " SPIFFE Federation Bootstrap Completed"
    echo "==========================="
}

update_agent_conf() {
    # Check if the required argument is provided
    if [ -z "$1" ]; then
        echo "Usage: update_agent_conf <new_cluster_name>"
        exit 1
    fi

    # Assign the new cluster name to a variable
    NEW_CLUSTER="$1"

    # Define input and output file paths
    INPUT_FILE="files/cluster/agent.conf"
    OUTPUT_DIR="clusters/${NEW_CLUSTER}"
    OUTPUT_FILE="${OUTPUT_DIR}/agent.conf"

    # Create the output directory if it does not exist
    mkdir -p "$OUTPUT_DIR"

    # Read the file and replace the required values
    sed -e "s/trust_domain = \".*\"/trust_domain = \"nsm.${NEW_CLUSTER}\"/" \
        -e "s/cluster = \".*\"/cluster = \"nsm.${NEW_CLUSTER}\"/" \
        "$INPUT_FILE" > "$OUTPUT_FILE"

    echo "Updated agent.conf saved to ${OUTPUT_FILE}"
}

update_clusterspiffeid_template() {
    # Check if the required argument is provided
    if [ -z "$1" ]; then
        echo "Usage: update_clusterspiffeid_template <new_cluster_name>"
        exit 1
    fi

    # Assign the new cluster name to a variable
    NEW_CLUSTER="$1"

    # Define input and output file paths
    INPUT_FILE="files/cluster/clusterspiffeid-template.yaml"
    OUTPUT_DIR="clusters/${NEW_CLUSTER}"
    OUTPUT_FILE="${OUTPUT_DIR}/clusterspiffeid-template.yaml"

    # Create the output directory if it does not exist
    mkdir -p "$OUTPUT_DIR"

    federatesWith=()  # Initialize an empty array

    # Loop to add the federatesWith
    local i
    for i in "${!clusters[@]}"; do
      if [[ "${clusters[$i]}" != "$NEW_CLUSTER" ]]; then
        federatesWith+=("\"nsm.${clusters[$i]}\"")
      fi
    done

    # Convert the array to a comma-separated string
    federatesWithString=$(IFS=,; echo "${federatesWith[*]}")    
    federatesWithString=$(echo "$federatesWithString" | sed 's/,/, /g')

    # Read the file and replace the required values using sed
    sed -e "s|spiffeIDTemplate: \".*\"|spiffeIDTemplate: \"spiffe://nsm.${NEW_CLUSTER}/ns/{{.PodMeta.Namespace}}/pod/{{.PodMeta.Name}}\"|" \
        -e "s|federatesWith: \[\]|federatesWith: [${federatesWithString}]|" \
        "$INPUT_FILE" > "$OUTPUT_FILE"

    echo "Updated clusterspiffeid-template.yaml saved to ${OUTPUT_FILE}"
}

update_kustomization(){
    # Check if the required argument is provided
    if [ -z "$1" ]; then
        echo "Usage: update_kustomization <new_cluster_name>"
        exit 1
    fi

    # Assign the new cluster name to a variable
    NEW_CLUSTER="$1"

    # Define input and output file paths
    INPUT_FILE="files/cluster/kustomization.yaml"
    OUTPUT_DIR="clusters/${NEW_CLUSTER}"
    OUTPUT_FILE="${OUTPUT_DIR}/kustomization.yaml"

    # Create the output directory if it does not exist
    mkdir -p "$OUTPUT_DIR"

    cp $INPUT_FILE $OUTPUT_FILE
    echo "Updated kustomization.yaml saved to ${OUTPUT_FILE}"
}

update_server(){
  # Check if the required argument is provided
  if [ -z "$1" ]; then
      echo "Usage: update_server <new_cluster_name>"
      exit 1
  fi

  # Assign the new cluster name to a variable
  NEW_CLUSTER="$1"

  # Define input and output file paths
  INPUT_FILE="files/cluster/server.conf"
  OUTPUT_DIR="clusters/${NEW_CLUSTER}"
  OUTPUT_FILE="${OUTPUT_DIR}/server.conf"

  # Create the output directory if it does not exist
  mkdir -p "$OUTPUT_DIR"

  # Initialize the federatesWith string
  federatesWith=""

  # Loop to add the federatesWith configuration for each cluster  
  local cluster
  for cluster in "${clusters[@]}"; do
    if [[ "$cluster" != "$NEW_CLUSTER" ]]; then
      federatesWith+="\n        federates_with \"nsm.${cluster}\" {\n"
      federatesWith+="          bundle_endpoint_url = \"https://spire-server.spire.my.${cluster}:8443\"\n"
      federatesWith+="          bundle_endpoint_profile \"https_spiffe\" {\n"
      federatesWith+="             endpoint_spiffe_id = \"spiffe://nsm.${cluster}/spire/server\"\n"
      federatesWith+="          }\n"
      federatesWith+="        }\n\n"
    fi
  done

  # Read the file and replace the required values using sed
  sed -e "s|trust_domain = \"\"|trust_domain = \"nsm.${NEW_CLUSTER}\"|" \
      -e "s|{cluster_name}|${NEW_CLUSTER}|" \
      -e "s|{federates_with}|${federatesWith}|" \
      "$INPUT_FILE" > "$OUTPUT_FILE"

  echo "Updated server.conf saved to ${OUTPUT_FILE}"
}

update_service_patch(){
    # Check if the required argument is provided
    if [ -z "$1" ]; then
        echo "Usage: update_service_patch <new_cluster_name>"
        exit 1
    fi

    # Assign the new cluster name to a variable
    NEW_CLUSTER="$1"

    # Define input and output file paths
    INPUT_FILE="files/cluster/service-patch.yaml"
    OUTPUT_DIR="clusters/${NEW_CLUSTER}"
    OUTPUT_FILE="${OUTPUT_DIR}/service-patch.yaml"

    # Create the output directory if it does not exist
    mkdir -p "$OUTPUT_DIR"

    cp $INPUT_FILE $OUTPUT_FILE
    echo "Updated service-patch.yaml saved to ${OUTPUT_FILE}"    
}

update_spire_controller_manager_config() {
    # Check if the required argument is provided
    if [ -z "$1" ]; then
        echo "Usage: update_spire_controller_manager_config <new_cluster_name>"
        exit 1
    fi

    # Assign the new cluster name to a variable
    NEW_CLUSTER="$1"

    # Define input and output file paths
    INPUT_FILE="files/cluster/spire-controller-manager-config.yaml"
    OUTPUT_DIR="clusters/${NEW_CLUSTER}"
    OUTPUT_FILE="${OUTPUT_DIR}/spire-controller-manager-config.yaml"

    # Create the output directory if it does not exist
    mkdir -p "$OUTPUT_DIR"

    # Read the file and replace the required values
    sed -e "s|{cluster_name}|${NEW_CLUSTER}|"\
        "$INPUT_FILE" > "$OUTPUT_FILE"

    echo "Updated spire-controller-manager-config.yaml saved to ${OUTPUT_FILE}"
}

create_files() {
  # Check if the required argument is provided
  if [ -z "$1" ]; then
      echo "Usage: update_spire_controller_manager_config <new_cluster_name>"
      exit 1
  fi
  mkdir ./clusters/"${cluster}"

  # Assign the new cluster name to a variable
  local NEW_CLUSTER="$1"

  echo "Creating the agent.conf file"
  update_agent_conf $NEW_CLUSTER

  echo "Creating the clusterspiffeid-template.yaml file"
  update_clusterspiffeid_template $NEW_CLUSTER

  echo "Creating the kustomization.yaml file"
  update_kustomization $NEW_CLUSTER

  echo "Creating the server.conf file"
  update_server $NEW_CLUSTER

  echo "Creating the service-patch.yaml file"
  update_service_patch $NEW_CLUSTER

  echo "Creating the spire-controller-manager-config.yaml file"
  update_spire_controller_manager_config $NEW_CLUSTER
}

base_files() {
  
  ./delete.sh

  echo "Removing the previously configured folder"
  rm -Rf ./clusters
  mkdir ./clusters

  echo "Copping base files"

  mkdir ./clusters/base
  cp -r ./files/base/* ./clusters/base/

  mkdir ./clusters/postgres
  cp -r ./files/postgres/* ./clusters/postgres/
  echo "Base files copied"  
}

# copy the base files for the spire each cluster
base_files

# Apply DNS configuration for each cluster
for i in "${!clusters[@]}"; do
  
  cluster="${clusters[$i]}"
  current_context="${clusters_context[$i]}"
  current_ip="${clusters_ip[$i]}"

  echo "=================================="
  echo " Configuring Cluster ${cluster}"
  echo "=================================="
  
  create_files $cluster

  kubectl --context=$current_context apply -k clusters/$cluster/

  kubectl --context=$current_context wait -n spire --timeout=3m --for=condition=ready pod -l app=spire-server

  kubectl --context=$current_context wait -n spire --timeout=1m --for=condition=ready pod -l app=spire-agent

  kubectl --context=$current_context apply -f ./clusters/$cluster/clusterspiffeid-template.yaml

  kubectl --context=$current_context apply -f ./clusters/base/clusterspiffeid-webhook-template.yaml    

  # Update the spire server svc to listen in the port 8443
  echo "Add port 8443 to the spire-server service"
  kubectl --context=$current_context apply -f ./clusters/base/server-statefulset-port-update.yaml
done

# setup the spiffe federation coping the bundles for the other servers
bootstrap_spiffe_federation 