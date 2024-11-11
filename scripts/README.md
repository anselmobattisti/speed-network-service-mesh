# Instalation

File to create the environment where the SPEED will be executed

## Clusters

Contain the scripts to create the clusters where the environment will be configured.

In particular, the cluster.sh file contains the list of the cluster name that will be created.

To create an environment with more clusters just add the name of the cluster inside the array of clusters.

## Load Balancer

We are using the Metallb loadbalancer to expose the services running inside the k8s to outside the cluster.

All the cluster are binded with the same Docker network (kind)

During the configuration of MetalLB, each cluster will be configured to bind IPs for a certain range (10 ips for cluster)