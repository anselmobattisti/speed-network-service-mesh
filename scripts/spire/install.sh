#!/bin/bash

# ref: https://github.com/networkservicemesh/deployments-k8s/tree/main/examples/spire

echo "==================="
echo " CONFIGURING SPIRE "
echo "==================="

source ../clusters.sh

update_agent_conf() {
    # Check if the required argument is provided
    if [ -z "$1" ]; then
        echo "Usage: update_agent_conf <new_cluster_name>"
        return 1
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
        return 1
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
    for i in "${!clusters[@]}"; do
      if [[ "${clusters[$i]}" != "$NEW_CLUSTER" ]]; then
        federatesWith+=("${clusters[$i]}")
      fi
    done

    # Convert the array to a comma-separated string
    federatesWithString=$(IFS=,; echo "${federatesWith[*]}")    

    # Read the file and replace the required values using sed
    sed -e "s|spiffeIDTemplate: \".*\"|spiffeIDTemplate: \"spiffe://nsm.${NEW_CLUSTER}/ns/{{.PodMeta.Namespace}}/pod/{{.PodMeta.Name}}\"|" \
        -e "s|federatesWith: \[\]|federatesWith: [${federatesWithString}]|" \
        "$INPUT_FILE" > "$OUTPUT_FILE"

    echo "Updated clusterspiffeid-template.yaml saved to ${OUTPUT_FILE}"
}

# Loop through each cluster context
for cluster in "${clusters[@]}"; do
  mkdir ./clusters/"${clusters}"

  update_agent_conf $cluster
  update_clusterspiffeid_template $cluster
done