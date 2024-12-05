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

# Structure 

In this instalattion, the cluster3 is where the NSM as registred, and in the other cluster is where the NSC and NSE are executed.

# Test

All the pods in the nsm-system, in all the clusters must be ready!

```shell
kubectl get pods -n nsm-system --context=kind-cluster1
kubectl get pods -n nsm-system --context=kind-cluster2
kubectl get pods -n nsm-system --context=kind-cluster3
```