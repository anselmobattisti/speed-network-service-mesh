# Metallb

Is a loadbalancer for the services. It exposes the services using one IP associated with the kind cluster. 

All the kind cluster are associted with the docker network kind. Thus, the metallb will associate ips in the range of the "Subnet" of this network.

```sh
docker network inspect kind
```

In our case the "Subnet" is "172.19.0.0/16", thus all the pods in all the clusters will be in this network. 

Each cluster will have a subnet of this subnet. The first ip and the number of ips available in each cluster are configured in the scripts/cluster.sh file.

## Install 

To install the metallb in all the clusters execute

```sh
./install.sh
```
After the execution, for each cluster will be presente the range of ips available in the cluster. This ips will be used by the metallb to expose the services.

## Check Instalation

### IP Address Pool

Execute the command to list the ips that can be used in the cluster.

```shell
kubectl get ipaddresspool -n metallb-system --context=kind-cluster1
```

Must list all the IPs in the cluster pool, including the ips in use.

### Create NGINX Services

To test if the instalation is working, we create one nginx service in each cluster using the script test_metallb.sh

After the execution of the script, in each cluster, an nginx service must be started and having an external ip

```shell
CLUSTER 1
----------
service/nginx exposed
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)        AGE
kubernetes   ClusterIP      10.96.0.1      <none>         443/TCP        17m
nginx        LoadBalancer   10.96.43.102   172.19.0.100   80:31271/TCP   0s

CLUSTER 2
----------
service/nginx exposed
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)        AGE
kubernetes   ClusterIP      10.96.0.1      <none>         443/TCP        16m
nginx        LoadBalancer   10.96.27.205   172.19.0.111   80:32726/TCP   0s
```

The IPs of each service must be related with the range of ips for the cluster where the service is executed.

This IP can be access from the host machine. The welcome NGINX message must be presented.