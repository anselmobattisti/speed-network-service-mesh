#!/bin/bash

# load the clusters definition
cluster_definition_load()
    if [[ ! -f ../clusters.sh ]]; then
        echo "Error: clusters.sh not found!"
        exit 1
    fi

    source ../clusters.sh