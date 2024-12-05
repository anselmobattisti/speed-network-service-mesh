# NSM over interdomain vL3 network

REF: https://github.com/networkservicemesh/deployments-k8s/tree/main/examples/interdomain/usecases/floating_vl3-basic

This example show how can be configured NSM over interdomain via vL3 network.


## Cluster 3

Before the execution, in the spire server there is one entry, which is the registry-k8s

```shell
kubectl exec spire-server-0 -n spire -c spire-server --context=kind-cluster3 -- bin/spire-server entry show
```

Install the components in the cluster3

```shell

# kubectl delete -k . --context=kind-cluster3

kubectl apply -k . --context=kind-cluster3
```

In the cluster 3 is created the NetworkService (NS)

 ```shell
kubectl get NetworkService -n ns-floating-vl3-basic --context=kind-cluster3
```

Must show the network service

```
NAME                 AGE
floating-vl3-basic   9m25s
```

To see the details of the NS

```shell
kubectl describe NetworkService -n ns-floating-vl3-basic floating-vl3-basic --context=kind-cluster3
```

The service that executes the IPAM component must have an EXTERNAL-IP. For some reason the example file that update the IPAM Service from ClusterIP to Loadbalancer was not working. Thus, I need to update the file that start the IPAM service to begin with loadbalance (app/vl3-ipam/vl3-ipam-service.yaml) instead ClusterIP that was configured previously.

```shell
kubectl get Service -n ns-floating-vl3-basic --context=kind-cluster3
```

In this point there is no entities registred in the SPIRE server

```shell
kubectl exec spire-server-0 -n spire -c spire-server --context=kind-cluster3 -- bin/spire-server entry show
```

It should return 2 entities, one for the registry-k8s and the other for the ns-floating-vl3-basic which is the NS that we created.

```
Found 2 entries
```


## Cluster 1

Check if all the components in the cluster1 is working 

```shell
kubectl get pods -n nsm-system --context=kind-cluster1
```

All the cluster must be in the running state

Install the components in cluster1

```shell
# kubectl delete -k . --context=kind-cluster1
kubectl apply -k . --context=kind-cluster1
```

List all the pods in the namespace. All of them must be in the Ready state

```shell
kubectl get pods -n ns-floating-vl3-basic --context=kind-cluster1
```

The client is a pod with alpine. We add the labels and the NSM is adding inside the pod a new container named cmd-nsc-init. If this container not started, the alpine pod will not be started to. If the alpine pod not execute see the log in the container cmd-nsc-init  inside the alpine pod.

```shell
kubectl logs alpine -n ns-floating-vl3-basic --context=kind-cluster1 -c cmd-nsc-init  --context=kind-cluster1
```

Analise the logs of the pod nse-vl3-vpp-1

```shell
kubectl logs nse-vl3-vpp-1 -n ns-floating-vl3-basic --context=kind-cluster1
```

## Cluster 2

Check if all the components in the cluster2 is working 

```shell
kubectl get pods -n nsm-system --context=kind-cluster2
```

All the cluster must be in the running state

Install the components in cluster2

```shell
# kubectl delete -k . --context=kind-cluster2
kubectl apply -k . --context=kind-cluster2
```

List all the pods in the namespace. All of them must be in the Ready state

```shell
kubectl get pods -n ns-floating-vl3-basic --context=kind-cluster2
```

```shell
kubectl logs alpine -n ns-floating-vl3-basic --context=kind-cluster1 -c cmd-nsc-init  --context=kind-cluster2
```

Analise the logs of the pod nse-vl3-vpp-2

```shell
kubectl logs nse-vl3-vpp-2 -n ns-floating-vl3-basic --context=kind-cluster2
```

# To Test The Connectivity

Access the alpine in the cluster2

```shell
kubectl exec -it alpine -n ns-floating-vl3-basic --context=kind-cluster2 -- sh

# get the ip 
ifconfig nsm-1
```
172.16.0.3
Enter in the alpine in cluster1

```shell
kubectl exec -it alpine -n ns-floating-vl3-basic --context=kind-cluster1 -- sh

# get the ip 
ping 172.16.0.3
```