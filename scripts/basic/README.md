# Basic Environment

This folder contain the scripts to install the NSM in the cluster with the basic setup.

In the last cluster of the clusters.sh file the registry-k8s service will be installed. 

In the other clusters will be installed the basic services.

## File Structure

* files/apps: The NSM instalation files
* files/cluster-worker: The template file for the worker clusters
* files/cluster-registry: The template file for the registry clusters

# The Process

For each cluster in the configured file we create a folder inside the foder clusters. The last cluster is the floating registry, it will run the k8s registry. The other clusters are the worker clusters.