# Spire

Is an implementation of SPIFE. It enable te secure comunication between pods. In prticular pods in different clusters.

It is necessary to install and configure in each cluster the spire.

## Install Script

The installation process create a folder for each cluster where the specific configuration files are created. The folder is clusters/cluster(n). Each created file is configured for the specific cluster.

The source files are hosted inside the "files" folder. The files/base folder is the same for all the clusters.

After creating the files for each cluster and executing apply the yaml files in each cluster, is necessary to create the federation.

To build the federation the keys from each cluster must be copied to the other.

## Folder Structure 

* files/base: has the generic files to configure the environment
* files/postgress: has the files to instantiate the postgres used by spire
* files/cluster: has the generic files for the cluster configuration
* clusters/cluster(n): for each cluster there will be a folder

## Debug

Check server health

```sh 
kubectl exec spire-server-0 -n spire -c spire-server --context=kind-cluster1 -- bin/spire-server healthcheck

kubectl exec spire-server-0 -n spire -c spire-server --context=kind-cluster2 -- bin/spire-server healthcheck

kubectl exec spire-server-0 -n spire -c spire-server --context=kind-cluster3 -- bin/spire-server healthcheck
```

Get the logs of the spire server on each cluster

```sh 
kubectl logs spire-server-0 -n spire --context=kind-cluster1
kubectl logs spire-server-0 -n spire --context=kind-cluster2
kubectl logs spire-server-0 -n spire --context=kind-cluster3
```

The service spire-server must listern in the port 8443

kubectl describe svc spire-server -n spire --context=kind-cluster3

```sh 
kubectl describe svc spire-server -n spire --context=kind-cluster1
kubectl describe svc spire-server -n spire --context=kind-cluster2
kubectl describe svc spire-server -n spire --context=kind-cluster3
```

Verify if the bundler where copied to the servers

```sh 
kubectl exec spire-server-0 -n spire -c spire-server --context=kind-cluster1 -- bin/spire-server bundle show

kubectl exec spire-server-0 -n spire -c spire-server  --context=kind-cluster2 -- bin/spire-server bundle show

kubectl exec spire-server-0 -n spire -c spire-server --context=kind-cluster3 -- bin/spire-server bundle show
```

List all the bundles in the spire server

```sh
kubectl --context=kind-cluster1 exec spire-server-0 -n spire -- bin/spire-server bundle list
kubectl --context=kind-cluster2 exec spire-server-0 -n spire -- bin/spire-server bundle list
kubectl --context=kind-cluster3 exec spire-server-0 -n spire -- bin/spire-server bundle list
```

Show the trust bundles, if executed in cluster3 it must present the data from cluster1 and cluster2

```sh
kubectl exec spire-server-0 -n spire -c spire-server -- bin/spire-server bundle list  -format spiffe
```

List all the trusted domains in the spire server

```sh
kubectl logs spire-server-0 -n spire -c spire-server --context=kind-cluster2 | grep "Trust domain is now managed"
```