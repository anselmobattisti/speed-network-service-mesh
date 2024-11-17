#!/bin/bash

# Clusters
#---------
# Define an array of cluster names
clusters=("cluster1" "cluster2" "cluster3")

# Define an array of context names
clusters_context=("kind-cluster1" "kind-cluster2" "kind-cluster3")

# Metallb
#---------
# The first ip used in the first cluster (191)
first_ip=100

# number of ips reserved for each cluster
ips_in_the_cluster=10