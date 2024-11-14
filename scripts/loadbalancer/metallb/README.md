# Metallb

Is a loadbalancer for the services. It exposes the services using one IP associated with the kind cluster.

## Check Instalation

### IP Address Pool

Must list all the available pools of IPs in the cluster

```shell
kubectl get ipaddresspool -n metallb-system
```

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

The ips of each service must be related with the range of ips for each cluster.
